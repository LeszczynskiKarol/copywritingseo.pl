// contact-form/index.mjs
// Lambda: copywritingseo-contact
// Przetwarza formularz kontaktowy i wysyła email przez SES

import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";
import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

const REGION = process.env.AWS_REGION || "eu-central-1";
const SES_REGION = "us-east-1";
const ses = new SESClient({ region: SES_REGION });
const s3 = new S3Client({ region: REGION });

const BUCKET = process.env.BUCKET_NAME || "copywritingseo-attachments";
const TO_EMAIL = "kontakt@copywritingseo.pl";
const FROM_EMAIL = "formularz@copywritingseo.pl";
const FROM_NAME = "CopywritingSEO.pl";

const ALLOWED_ORIGINS = [
  "https://www.copywritingseo.pl",
  "https://copywritingseo.pl",
  "http://localhost:4321",
];

function escapeHtml(str) {
  return String(str || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function formatSize(bytes) {
  if (bytes < 1024) return bytes + " B";
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB";
  return (bytes / (1024 * 1024)).toFixed(1) + " MB";
}

export const handler = async (event) => {
  const origin = event.headers?.origin || "";
  const allowOrigin = ALLOWED_ORIGINS.includes(origin)
    ? origin
    : "https://www.copywritingseo.pl";

  const headers = {
    "Access-Control-Allow-Origin": allowOrigin,
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Content-Type": "application/json",
  };

  if (event.requestContext?.http?.method === "OPTIONS") {
    return { statusCode: 200, headers, body: "" };
  }

  try {
    const body = JSON.parse(event.body || "{}");
    const {
      name,
      email,
      phone,
      message,
      serviceType,
      website,
      budget,
      attachments,
    } = body;

    // Walidacja
    if (!name || !email || !message) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({
          error: "Brak wymaganych pól (name, email, message)",
        }),
      };
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ error: "Nieprawidłowy adres email" }),
      };
    }

    // Generuj linki do pobrania załączników (ważne 7 dni)
    let attachmentsHtml = "";
    if (attachments && attachments.length > 0) {
      const attachmentLinks = [];
      for (const att of attachments) {
        try {
          const command = new GetObjectCommand({
            Bucket: BUCKET,
            Key: att.key,
          });
          const downloadUrl = await getSignedUrl(s3, command, {
            expiresIn: 7 * 24 * 60 * 60,
          });
          attachmentLinks.push(
            `<li style="margin-bottom:4px"><a href="${downloadUrl}" style="color:#1d4ed8;text-decoration:underline">${escapeHtml(att.name)}</a> <span style="color:#94a3b8;font-size:12px">(${formatSize(att.size || 0)})</span></li>`,
          );
        } catch (err) {
          console.error("Error generating download URL for:", att.key, err);
          attachmentLinks.push(
            `<li>${escapeHtml(att.name)} — <em style="color:#94a3b8">błąd generowania linku</em></li>`,
          );
        }
      }
      attachmentsHtml = `
        <tr>
          <td style="padding:12px 20px;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;font-weight:600;color:#1e293b;vertical-align:top;width:140px;border-bottom:1px solid #e2e8f0">Załączniki:</td>
          <td style="padding:12px 20px;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;color:#475569;border-bottom:1px solid #e2e8f0">
            <ul style="margin:0;padding-left:20px;list-style:none">${attachmentLinks.join("")}</ul>
            <p style="font-size:11px;color:#94a3b8;margin-top:6px">Linki ważne 7 dni</p>
          </td>
        </tr>`;
    }

    // Email HTML — CopywritingSEO design: blue/indigo, professional, clean
    const htmlBody = `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;background:#f8fafc">
  <div style="max-width:620px;margin:0 auto;padding:32px 16px">
    
    <!-- Header -->
    <div style="border-top:3px solid #1d4ed8;padding-top:16px;margin-bottom:8px">
      <table style="width:100%"><tr>
        <td style="font-size:20px;font-weight:700;color:#1e293b;letter-spacing:-0.02em">
          <span style="display:inline-block;width:28px;height:28px;background:linear-gradient(135deg,#1d4ed8,#7c3aed);color:#fff;text-align:center;line-height:28px;border-radius:6px;font-size:14px;font-weight:800;margin-right:8px;vertical-align:middle">C</span>
          CopywritingSEO
        </td>
        <td style="text-align:right;font-size:10px;color:#94a3b8;letter-spacing:0.08em;text-transform:uppercase">Nowe zapytanie</td>
      </tr></table>
    </div>
    <div style="border-bottom:1px solid #e2e8f0;margin-bottom:24px"></div>

    <!-- Title -->
    <h1 style="font-size:22px;font-weight:700;color:#1e293b;margin:0 0 6px;line-height:1.3">Nowe zapytanie z formularza kontaktowego</h1>
    <p style="font-size:11px;color:#94a3b8;margin:0 0 24px;letter-spacing:0.04em">${new Date().toLocaleDateString("pl-PL", { year: "numeric", month: "long", day: "numeric", hour: "2-digit", minute: "2-digit" })}</p>

    <!-- Data table -->
    <table style="width:100%;border-collapse:collapse;background:#ffffff;border:1px solid #e2e8f0;border-radius:8px">
      <tr>
        <td style="padding:12px 20px;font-weight:600;color:#1e293b;width:140px;border-bottom:1px solid #e2e8f0">Nadawca:</td>
        <td style="padding:12px 20px;color:#475569;border-bottom:1px solid #e2e8f0">${escapeHtml(name)}</td>
      </tr>
      <tr>
        <td style="padding:12px 20px;font-weight:600;color:#1e293b;border-bottom:1px solid #e2e8f0">Email:</td>
        <td style="padding:12px 20px;border-bottom:1px solid #e2e8f0">
          <a href="mailto:${escapeHtml(email)}" style="color:#1d4ed8;text-decoration:underline">${escapeHtml(email)}</a>
        </td>
      </tr>
      ${phone ? `<tr>
        <td style="padding:12px 20px;font-weight:600;color:#1e293b;border-bottom:1px solid #e2e8f0">Telefon:</td>
        <td style="padding:12px 20px;color:#475569;border-bottom:1px solid #e2e8f0">${escapeHtml(phone)}</td>
      </tr>` : ""}
      ${serviceType ? `<tr>
        <td style="padding:12px 20px;font-weight:600;color:#1e293b;border-bottom:1px solid #e2e8f0">Usługa:</td>
        <td style="padding:12px 20px;color:#475569;border-bottom:1px solid #e2e8f0">
          <span style="background:#eff6ff;color:#1d4ed8;padding:3px 10px;font-size:13px;border-radius:4px;font-weight:600">${escapeHtml(serviceType)}</span>
        </td>
      </tr>` : ""}
      ${website ? `<tr>
        <td style="padding:12px 20px;font-weight:600;color:#1e293b;border-bottom:1px solid #e2e8f0">Strona www:</td>
        <td style="padding:12px 20px;border-bottom:1px solid #e2e8f0">
          <a href="${escapeHtml(website)}" style="color:#1d4ed8;text-decoration:underline">${escapeHtml(website)}</a>
        </td>
      </tr>` : ""}
      ${budget ? `<tr>
        <td style="padding:12px 20px;font-weight:600;color:#1e293b;border-bottom:1px solid #e2e8f0">Budżet:</td>
        <td style="padding:12px 20px;color:#475569;border-bottom:1px solid #e2e8f0">${escapeHtml(budget)}</td>
      </tr>` : ""}
      <tr>
        <td style="padding:12px 20px;font-weight:600;color:#1e293b;vertical-align:top;border-bottom:1px solid #e2e8f0">Wiadomość:</td>
        <td style="padding:12px 20px;color:#475569;line-height:1.65;border-bottom:1px solid #e2e8f0">${escapeHtml(message).replace(/\n/g, "<br>")}</td>
      </tr>
      ${attachmentsHtml}
    </table>

    <!-- Reply button -->
    <div style="text-align:center;padding:28px 0">
      <a href="mailto:${escapeHtml(email)}?subject=Re: Zapytanie — CopywritingSEO.pl" 
         style="display:inline-block;padding:12px 32px;background:#1d4ed8;color:#fff;text-decoration:none;font-size:14px;font-weight:600;border-radius:8px">
        Odpowiedz na zapytanie →
      </a>
    </div>

    <!-- Footer -->
    <div style="border-top:1px solid #e2e8f0;padding-top:12px;text-align:center">
      <p style="font-size:10px;color:#94a3b8;letter-spacing:0.06em;text-transform:uppercase">
        Formularz kontaktowy · CopywritingSEO.pl · SEO Copywriting & Content Strategy
      </p>
    </div>
  </div>
</body>
</html>`;

    const command = new SendEmailCommand({
      Source: `${FROM_NAME} <${FROM_EMAIL}>`,
      Destination: { ToAddresses: [TO_EMAIL] },
      ReplyToAddresses: [email],
      Message: {
        Subject: {
          Data: `Nowe zapytanie: ${name}${serviceType ? " — " + serviceType : ""}`,
          Charset: "UTF-8",
        },
        Body: {
          Html: { Data: htmlBody, Charset: "UTF-8" },
        },
      },
    });

    await ses.send(command);

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ success: true }),
    };
  } catch (error) {
    console.error("Contact form error:", error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: "Błąd wysyłania wiadomości" }),
    };
  }
};
