#!/bin/bash
# Deploy CopywritingSEO.pl to AWS S3 + CloudFront
# Usage: ./deploy.sh

set -e

BUCKET="copywritingseo.pl"
DISTRIBUTION_ID="E1LN5XTQYDWI7O" # CloudFront distribution for copywritingseo.pl (alias-verified via aws cloudfront list-distributions)
REGION="eu-central-1"

echo "🔨 Building site..."
npm run build

echo "📤 Uploading to S3..."
aws s3 sync dist/ s3://$BUCKET \
  --delete \
  --region $REGION \
  --cache-control "public, max-age=31536000, immutable" \
  --exclude "*.html" \
  --exclude "sitemap*.xml" \
  --exclude "robots.txt" \
  --exclude "rss.xml"

# HTML files with shorter cache
aws s3 sync dist/ s3://$BUCKET \
  --region $REGION \
  --cache-control "public, max-age=3600, must-revalidate" \
  --include "*.html" \
  --include "sitemap*.xml" \
  --include "robots.txt" \
  --include "rss.xml" \
  --content-type "text/html; charset=utf-8" \
  --exclude "*" \
  --include "*.html"

if [ -n "$DISTRIBUTION_ID" ]; then
  echo "🔄 Invalidating CloudFront cache..."
  aws cloudfront create-invalidation \
    --distribution-id $DISTRIBUTION_ID \
    --paths "/*" \
    --region us-east-1
fi

echo "✅ Deploy complete!"
