#!/bin/bash
# ============================================================
# FIX: Krok 8 — DNS (MX, SPF, DMARC, MAIL FROM)
# Naprawiony escaping TXT recordów
# ============================================================

set -e

DOMAIN="copywritingseo.pl"
SES_REGION="us-east-1"
HOSTED_ZONE_ID="Z0629459BFTPRQ47N4LL"

echo ">>> FIX: DNS records dla $DOMAIN"
echo ""

# Krok 8: MX, TXT (SPF + google-site-verification), DMARC, MAIL FROM
# Problem: TXT record wymaga podwójnych cudzysłowów WEWNĄTRZ wartości
# Route53 API wymaga: "\"wartość\""

aws route53 change-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch '{
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "copywritingseo.pl",
          "Type": "MX",
          "TTL": 300,
          "ResourceRecords": [
            {"Value": "10 web1.aftermarket.hosting."}
          ]
        }
      },
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "copywritingseo.pl",
          "Type": "TXT",
          "TTL": 300,
          "ResourceRecords": [
            {"Value": "\"v=spf1 include:amazonses.com include:_spf.aftermarket.pl ~all\""},
            {"Value": "\"google-site-verification=WAB7sJd4XAHZesY-2ITPsaeuUAvvErWnZZ8fvHoQwEs\""}
          ]
        }
      },
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "_dmarc.copywritingseo.pl",
          "Type": "TXT",
          "TTL": 300,
          "ResourceRecords": [
            {"Value": "\"v=DMARC1; p=none;\""}
          ]
        }
      },
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "mail.copywritingseo.pl",
          "Type": "MX",
          "TTL": 300,
          "ResourceRecords": [
            {"Value": "10 feedback-smtp.us-east-1.amazonses.com"}
          ]
        }
      },
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "mail.copywritingseo.pl",
          "Type": "TXT",
          "TTL": 300,
          "ResourceRecords": [
            {"Value": "\"v=spf1 include:amazonses.com ~all\""}
          ]
        }
      }
    ]
  }'

echo ""
echo "    MX copywritingseo.pl → web1.aftermarket.hosting ✓"
echo "    SPF copywritingseo.pl → amazonses + aftermarket ✓"
echo "    Google Site Verification → zachowany ✓"
echo "    DMARC → p=none ✓"
echo "    MAIL FROM mail.copywritingseo.pl → feedback-smtp ✓"
echo ""

# Krok 9: SES MAIL FROM
echo ">>> SES: MAIL FROM subdomain"
aws ses set-identity-mail-from-domain \
  --identity "$DOMAIN" \
  --mail-from-domain "mail.${DOMAIN}" \
  --region "$SES_REGION" 2>/dev/null || echo "    MAIL FROM juz ustawiony"
echo "    MAIL FROM: mail.${DOMAIN} ✓"
echo ""

# Sprawdź SES
echo ">>> Sprawdzam SES..."
sleep 5
SES_CHECK=$(aws ses get-identity-verification-attributes \
  --identities "$DOMAIN" \
  --region "$SES_REGION" \
  --query "VerificationAttributes.\"${DOMAIN}\".VerificationStatus" \
  --output text 2>/dev/null || echo "Pending")
echo "    Status SES: $SES_CHECK"

if [ "$SES_CHECK" != "Success" ]; then
  echo ""
  echo "    ⚠️  SES jeszcze nie zweryfikowany — DNS potrzebuje 1-5 minut."
  echo "    Sprawdz za chwile:"
  echo "    aws ses get-identity-verification-attributes --identities $DOMAIN --region $SES_REGION"
fi

echo ""
echo "============================================"
echo "  GOTOWE!"
echo "============================================"
echo ""
echo "  API URL:     https://84rzs9nddi.execute-api.eu-central-1.amazonaws.com"
echo ""
echo "  POCZTA:"
echo "  Odbiorcza:   kontakt@copywritingseo.pl → aftermarket (web1.aftermarket.hosting)"
echo "  Wysyłka SES: formularz@copywritingseo.pl → SES (us-east-1)"
echo ""
echo "  NASTĘPNE KROKI:"
echo ""
echo "  1. W kontakt.astro zamien API_URL:"
echo "     const API_URL = 'https://84rzs9nddi.execute-api.eu-central-1.amazonaws.com';"
echo ""
echo "  2. SES sandbox — zweryfikuj email docelowy:"
echo "     aws ses verify-email-identity --email-address kontakt@copywritingseo.pl --region us-east-1"
echo ""
echo "  3. LUB wyjdz z sandbox (Production Access w konsoli SES)"
echo ""
echo "  4. Sprawdz czy aftermarket SPF dziala:"
echo "     dig TXT _spf.aftermarket.pl"
echo "     Jesli nie istnieje, zamien SPF na:"
echo "     v=spf1 include:amazonses.com a:web1.aftermarket.hosting ~all"
echo "============================================"