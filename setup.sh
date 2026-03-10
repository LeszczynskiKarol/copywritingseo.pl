#!/bin/bash
# ============================================================
# SETUP: Infrastruktura AWS dla statycznej strony
# copywritingseo.pl (Astro SSG → S3 + CloudFront)
#
# Wzorowane na mekra.pl
# Kompatybilny z Windows Git Bash / MINGW64
# ============================================================

set -e

REGION="eu-central-1"
ACM_REGION="us-east-1"  # CloudFront wymaga certyfikatu w us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
DOMAIN="copywritingseo.pl"
HOSTED_ZONE_ID="Z0629459BFTPRQ47N4LL"
BUCKET_WWW="www.${DOMAIN}"
BUCKET_APEX="${DOMAIN}"

echo "============================================"
echo "  ${DOMAIN} — Setup AWS"
echo "============================================"
echo "Account: $ACCOUNT_ID"
echo "Region:  $REGION"
echo "ACM:     $ACM_REGION"
echo "============================================"
echo ""

# ============================================================
# 1. S3 BUCKET: www.copywritingseo.pl (content)
# ============================================================
echo ">>> [1/8] S3 bucket: $BUCKET_WWW (content)"

aws s3api create-bucket \
  --bucket "$BUCKET_WWW" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" \
  2>/dev/null || echo "    Bucket juz istnieje"

# Wylacz block public access (CloudFront OAC nie wymaga publicznego dostępu,
# ale na wszelki wypadek zostawiamy zablokowany — OAC sam uzyska dostep)
aws s3api put-public-access-block \
  --bucket "$BUCKET_WWW" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
echo "    Public access zablokowany"
echo ""

# ============================================================
# 2. S3 BUCKET: copywritingseo.pl (redirect → www)
# ============================================================
echo ">>> [2/8] S3 bucket: $BUCKET_APEX (redirect → www)"

aws s3api create-bucket \
  --bucket "$BUCKET_APEX" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" \
  2>/dev/null || echo "    Bucket juz istnieje"

aws s3api put-public-access-block \
  --bucket "$BUCKET_APEX" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Redirect na www
aws s3 website "s3://${BUCKET_APEX}" \
  --index-document index.html \
  --error-document 404.html 2>/dev/null || true

aws s3api put-bucket-website \
  --bucket "$BUCKET_APEX" \
  --website-configuration '{
    "RedirectAllRequestsTo": {
      "HostName": "www.'"${DOMAIN}"'",
      "Protocol": "https"
    }
  }'
echo "    Redirect: ${DOMAIN} → https://www.${DOMAIN}"
echo ""

# ============================================================
# 3. ACM CERTIFICATE (us-east-1 — wymagane przez CloudFront)
# ============================================================
echo ">>> [3/8] ACM: Certyfikat SSL w $ACM_REGION"

# Sprawdz czy certyfikat juz istnieje
EXISTING_CERT_ARN=$(aws acm list-certificates \
  --region "$ACM_REGION" \
  --query "CertificateSummaryList[?DomainName=='${DOMAIN}'].CertificateArn" \
  --output text 2>/dev/null)

if [ -n "$EXISTING_CERT_ARN" ] && [ "$EXISTING_CERT_ARN" != "None" ]; then
  CERT_ARN="$EXISTING_CERT_ARN"
  echo "    Certyfikat juz istnieje: $CERT_ARN"
else
  CERT_ARN=$(aws acm request-certificate \
    --domain-name "$DOMAIN" \
    --subject-alternative-names "www.${DOMAIN}" \
    --validation-method DNS \
    --region "$ACM_REGION" \
    --query "CertificateArn" --output text)
  echo "    Nowy certyfikat: $CERT_ARN"

  echo "    Czekam 10s na dane walidacyjne..."
  sleep 10

  # Pobierz rekordy walidacyjne DNS
  VALIDATION_JSON=$(aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region "$ACM_REGION" \
    --query "Certificate.DomainValidationOptions")

  # Wyciagnij unikalne pary CNAME Name→Value
  CNAME_CHANGES=""
  SEEN_NAMES=""

  while IFS= read -r line; do
    CNAME_NAME=$(echo "$line" | cut -d'|' -f1)
    CNAME_VALUE=$(echo "$line" | cut -d'|' -f2)

    # Pomijaj duplikaty (wildcard i apex maja ten sam CNAME)
    if echo "$SEEN_NAMES" | grep -q "$CNAME_NAME"; then
      continue
    fi
    SEEN_NAMES="$SEEN_NAMES $CNAME_NAME"

    CNAME_CHANGES="${CNAME_CHANGES}{\"Action\":\"UPSERT\",\"ResourceRecordSet\":{\"Name\":\"${CNAME_NAME}\",\"Type\":\"CNAME\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"${CNAME_VALUE}\"}]}},"
  done < <(echo "$VALIDATION_JSON" | python3 -c "
import json, sys
data = json.load(sys.stdin)
seen = set()
for d in data:
    r = d.get('ResourceRecord', {})
    name = r.get('Name', '')
    value = r.get('Value', '')
    if name and name not in seen:
        seen.add(name)
        print(f'{name}|{value}')
" 2>/dev/null || echo "$VALIDATION_JSON" | jq -r '.[] | select(.ResourceRecord) | "\(.ResourceRecord.Name)|\(.ResourceRecord.Value)"' 2>/dev/null | sort -u)

  # Usun ostatni przecinek
  CNAME_CHANGES="${CNAME_CHANGES%,}"

  if [ -n "$CNAME_CHANGES" ]; then
    aws route53 change-resource-record-sets \
      --hosted-zone-id "$HOSTED_ZONE_ID" \
      --change-batch "{\"Changes\":[${CNAME_CHANGES}]}" > /dev/null
    echo "    Rekordy walidacyjne CNAME dodane do Route53 ✓"
  fi

  echo "    Czekam na walidacje certyfikatu (max 5 min)..."
  aws acm wait certificate-validated \
    --certificate-arn "$CERT_ARN" \
    --region "$ACM_REGION" 2>/dev/null || {
    echo "    ⚠️  Certyfikat jeszcze nie zwalidowany."
    echo "    Sprawdz pozniej: aws acm describe-certificate --certificate-arn $CERT_ARN --region $ACM_REGION"
    echo "    Kontynuuje setup — CloudFront zadziala jak certyfikat bedzie ISSUED."
  }
fi

echo "    CERT_ARN: $CERT_ARN"
echo ""

# ============================================================
# 4. CloudFront OAC (Origin Access Control)
# ============================================================
echo ">>> [4/8] CloudFront: OAC"

OAC_NAME="OAC-${BUCKET_WWW}"

EXISTING_OAC_ID=$(aws cloudfront list-origin-access-controls \
  --query "OriginAccessControlList.Items[?Name=='${OAC_NAME}'].Id" \
  --output text 2>/dev/null)

if [ -n "$EXISTING_OAC_ID" ] && [ "$EXISTING_OAC_ID" != "None" ]; then
  OAC_ID="$EXISTING_OAC_ID"
  echo "    OAC juz istnieje: $OAC_ID"
else
  OAC_ID=$(aws cloudfront create-origin-access-control \
    --origin-access-control-config "{
      \"Name\": \"${OAC_NAME}\",
      \"Description\": \"OAC for ${BUCKET_WWW}\",
      \"SigningProtocol\": \"sigv4\",
      \"SigningBehavior\": \"always\",
      \"OriginAccessControlOriginType\": \"s3\"
    }" \
    --query "OriginAccessControl.Id" --output text)
  echo "    Utworzono OAC: $OAC_ID"
fi
echo ""

# ============================================================
# 5. CloudFront DISTRIBUTION: www.copywritingseo.pl
# ============================================================
echo ">>> [5/8] CloudFront: www.${DOMAIN}"

S3_ORIGIN="${BUCKET_WWW}.s3.${REGION}.amazonaws.com"

EXISTING_WWW_DIST=$(aws cloudfront list-distributions \
  --query "DistributionList.Items[?Aliases.Items[0]=='www.${DOMAIN}'].Id" \
  --output text 2>/dev/null)

if [ -n "$EXISTING_WWW_DIST" ] && [ "$EXISTING_WWW_DIST" != "None" ]; then
  WWW_DIST_ID="$EXISTING_WWW_DIST"
  WWW_DIST_DOMAIN=$(aws cloudfront get-distribution \
    --id "$WWW_DIST_ID" \
    --query "Distribution.DomainName" --output text)
  echo "    Dystrybucja www juz istnieje: $WWW_DIST_ID ($WWW_DIST_DOMAIN)"
else
  WWW_DIST_CONFIG='{
    "CallerReference": "www-'"${DOMAIN}"'-'"$(date +%s)"'",
    "Aliases": {
      "Quantity": 1,
      "Items": ["www.'"${DOMAIN}"'"]
    },
    "DefaultRootObject": "index.html",
    "Origins": {
      "Quantity": 1,
      "Items": [{
        "Id": "S3-www-'"${DOMAIN}"'",
        "DomainName": "'"${S3_ORIGIN}"'",
        "OriginAccessControlId": "'"${OAC_ID}"'",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }]
    },
    "DefaultCacheBehavior": {
      "TargetOriginId": "S3-www-'"${DOMAIN}"'",
      "ViewerProtocolPolicy": "redirect-to-https",
      "AllowedMethods": {
        "Quantity": 2,
        "Items": ["GET", "HEAD"],
        "CachedMethods": {
          "Quantity": 2,
          "Items": ["GET", "HEAD"]
        }
      },
      "CachePolicyId": "658327ea-f89d-4fab-a63d-7e88639e58f6",
      "Compress": true,
      "FunctionAssociations": {
        "Quantity": 0
      }
    },
    "CustomErrorResponses": {
      "Quantity": 1,
      "Items": [{
        "ErrorCode": 403,
        "ResponsePagePath": "/404.html",
        "ResponseCode": "404",
        "ErrorCachingMinTTL": 300
      }]
    },
    "Comment": "www.'"${DOMAIN}"'",
    "PriceClass": "PriceClass_100",
    "Enabled": true,
    "ViewerCertificate": {
      "ACMCertificateArn": "'"${CERT_ARN}"'",
      "SSLSupportMethod": "sni-only",
      "MinimumProtocolVersion": "TLSv1.2_2021"
    },
    "HttpVersion": "http2and3"
  }'

  WWW_DIST_RESULT=$(aws cloudfront create-distribution \
    --distribution-config "$WWW_DIST_CONFIG" \
    --query "Distribution.[Id,DomainName]" --output text)

  WWW_DIST_ID=$(echo "$WWW_DIST_RESULT" | awk '{print $1}')
  WWW_DIST_DOMAIN=$(echo "$WWW_DIST_RESULT" | awk '{print $2}')
  echo "    Utworzono: $WWW_DIST_ID ($WWW_DIST_DOMAIN)"
fi

# S3 bucket policy dla OAC
echo "    Ustawiam bucket policy dla CloudFront OAC..."
aws s3api put-bucket-policy \
  --bucket "$BUCKET_WWW" \
  --policy '{
    "Version": "2012-10-17",
    "Statement": [{
      "Sid": "AllowCloudFrontOAC",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::'"${BUCKET_WWW}"'/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::'"${ACCOUNT_ID}"':distribution/'"${WWW_DIST_ID}"'"
        }
      }
    }]
  }'
echo "    Bucket policy OK ✓"
echo ""

# ============================================================
# 6. CloudFront DISTRIBUTION: copywritingseo.pl (redirect)
# ============================================================
echo ">>> [6/8] CloudFront: ${DOMAIN} (redirect → www)"

# Dla apex redirect uzywamy S3 website endpoint jako custom origin
S3_WEBSITE_ORIGIN="${BUCKET_APEX}.s3-website.${REGION}.amazonaws.com"

EXISTING_APEX_DIST=$(aws cloudfront list-distributions \
  --query "DistributionList.Items[?Aliases.Items[0]=='${DOMAIN}'].Id" \
  --output text 2>/dev/null)

if [ -n "$EXISTING_APEX_DIST" ] && [ "$EXISTING_APEX_DIST" != "None" ]; then
  APEX_DIST_ID="$EXISTING_APEX_DIST"
  APEX_DIST_DOMAIN=$(aws cloudfront get-distribution \
    --id "$APEX_DIST_ID" \
    --query "Distribution.DomainName" --output text)
  echo "    Dystrybucja apex juz istnieje: $APEX_DIST_ID ($APEX_DIST_DOMAIN)"
else
  APEX_DIST_CONFIG='{
    "CallerReference": "apex-'"${DOMAIN}"'-'"$(date +%s)"'",
    "Aliases": {
      "Quantity": 1,
      "Items": ["'"${DOMAIN}"'"]
    },
    "DefaultRootObject": "",
    "Origins": {
      "Quantity": 1,
      "Items": [{
        "Id": "S3-website-'"${DOMAIN}"'",
        "DomainName": "'"${S3_WEBSITE_ORIGIN}"'",
        "CustomOriginConfig": {
          "HTTPPort": 80,
          "HTTPSPort": 443,
          "OriginProtocolPolicy": "http-only"
        }
      }]
    },
    "DefaultCacheBehavior": {
      "TargetOriginId": "S3-website-'"${DOMAIN}"'",
      "ViewerProtocolPolicy": "redirect-to-https",
      "AllowedMethods": {
        "Quantity": 2,
        "Items": ["GET", "HEAD"],
        "CachedMethods": {
          "Quantity": 2,
          "Items": ["GET", "HEAD"]
        }
      },
      "CachePolicyId": "658327ea-f89d-4fab-a63d-7e88639e58f6",
      "Compress": true
    },
    "Comment": "'"${DOMAIN}"' redirect to www",
    "PriceClass": "PriceClass_100",
    "Enabled": true,
    "ViewerCertificate": {
      "ACMCertificateArn": "'"${CERT_ARN}"'",
      "SSLSupportMethod": "sni-only",
      "MinimumProtocolVersion": "TLSv1.2_2021"
    },
    "HttpVersion": "http2and3"
  }'

  APEX_DIST_RESULT=$(aws cloudfront create-distribution \
    --distribution-config "$APEX_DIST_CONFIG" \
    --query "Distribution.[Id,DomainName]" --output text)

  APEX_DIST_ID=$(echo "$APEX_DIST_RESULT" | awk '{print $1}')
  APEX_DIST_DOMAIN=$(echo "$APEX_DIST_RESULT" | awk '{print $2}')
  echo "    Utworzono: $APEX_DIST_ID ($APEX_DIST_DOMAIN)"
fi
echo ""

# ============================================================
# 7. Route53 DNS
# ============================================================
echo ">>> [7/8] Route53: DNS records"

aws route53 change-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch '{
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'"${DOMAIN}"'",
          "Type": "A",
          "AliasTarget": {
            "HostedZoneId": "Z2FDTNDATAQYW2",
            "DNSName": "'"${APEX_DIST_DOMAIN}"'",
            "EvaluateTargetHealth": false
          }
        }
      },
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "www.'"${DOMAIN}"'",
          "Type": "A",
          "AliasTarget": {
            "HostedZoneId": "Z2FDTNDATAQYW2",
            "DNSName": "'"${WWW_DIST_DOMAIN}"'",
            "EvaluateTargetHealth": false
          }
        }
      }
    ]
  }' > /dev/null

echo "    A ${DOMAIN} → ${APEX_DIST_DOMAIN} ✓"
echo "    A www.${DOMAIN} → ${WWW_DIST_DOMAIN} ✓"
echo ""

# ============================================================
# 8. CloudFront Function: URL rewriting (trailing slash → index.html)
# ============================================================
echo ">>> [8/8] CloudFront Function: URL rewrite (opcjonalne dla Astro)"

CF_FUNC_NAME="copywritingseo-url-rewrite"

EXISTING_FUNC=$(aws cloudfront list-functions \
  --query "FunctionList.Items[?Name=='${CF_FUNC_NAME}'].Name" \
  --output text 2>/dev/null)

if [ -n "$EXISTING_FUNC" ] && [ "$EXISTING_FUNC" != "None" ]; then
  echo "    Funkcja juz istnieje — pomiń"
else
  # Tworzymy plik tymczasowy z kodem funkcji
  FUNC_CODE_FILE="/tmp/cf-func-${DOMAIN}.js"
  cat > "$FUNC_CODE_FILE" << 'CFEOF'
function handler(event) {
  var request = event.request;
  var uri = request.uri;

  // Jezeli URI konczy sie na / — dodaj index.html
  if (uri.endsWith('/')) {
    request.uri += 'index.html';
  }
  // Jezeli URI nie ma rozszerzenia — dodaj /index.html
  else if (!uri.includes('.')) {
    request.uri += '/index.html';
  }

  return request;
}
CFEOF

  aws cloudfront create-function \
    --name "$CF_FUNC_NAME" \
    --function-config '{"Comment":"URL rewrite for Astro SSG","Runtime":"cloudfront-js-2.0"}' \
    --function-code "fileb://${FUNC_CODE_FILE}" > /dev/null 2>&1

  # Publikuj
  ETAG=$(aws cloudfront describe-function \
    --name "$CF_FUNC_NAME" \
    --query "ETag" --output text)

  aws cloudfront publish-function \
    --name "$CF_FUNC_NAME" \
    --if-match "$ETAG" > /dev/null 2>&1

  echo "    CloudFront Function utworzona i opublikowana ✓"
  echo ""
  echo "    ⚠️  RĘCZNIE podepnij funkcję do dystrybucji www:"
  echo "    W konsoli CloudFront → www distribution → Behaviors → Edit"
  echo "    → Function associations → Viewer request → ${CF_FUNC_NAME}"
  echo "    (Albo zaktualizuj distribution config z FunctionAssociations)"

  rm -f "$FUNC_CODE_FILE"
fi
echo ""

# ============================================================
# SUMMARY
# ============================================================
echo "============================================"
echo "  GOTOWE! ${DOMAIN}"
echo "============================================"
echo ""
echo "  S3 Content:     s3://${BUCKET_WWW}"
echo "  S3 Redirect:    s3://${BUCKET_APEX} → https://www.${DOMAIN}"
echo "  CloudFront www: ${WWW_DIST_ID:-'sprawdz'} (${WWW_DIST_DOMAIN:-'...'})"
echo "  CloudFront apex:${APEX_DIST_ID:-'sprawdz'} (${APEX_DIST_DOMAIN:-'...'})"
echo "  Certyfikat:     $CERT_ARN"
echo ""
echo "  DEPLOY ASTRO BUILD:"
echo "  astro build"
echo "  aws s3 sync dist/ s3://${BUCKET_WWW} --delete --region ${REGION}"
echo "  aws cloudfront create-invalidation --distribution-id ${WWW_DIST_ID:-'DIST_ID'} --paths '/*'"
echo ""
echo "  ⚠️  UWAGI:"
echo "  1. Certyfikat ACM musi byc ISSUED zanim CloudFront zacznie dzialac"
echo "  2. Propagacja CloudFront trwa 5-15 min"
echo "  3. Podepnij CF Function do www distribution (URL rewrite)"
echo "============================================"