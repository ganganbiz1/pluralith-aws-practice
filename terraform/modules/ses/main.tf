resource "aws_ses_domain_identity" "main" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "aws_ses_domain_mail_from" "main" {
  domain           = aws_ses_domain_identity.main.domain
  mail_from_domain = "mail.${var.domain}"
}


resource "aws_route53_record" "ses_verification" {
  zone_id = var.host_zone_id
  name    = aws_ses_domain_identity.main.verification_token
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.main.verification_token]
}

resource "aws_route53_record" "dkim_record" {
  count   = 3
  zone_id = var.host_zone_id
  name    = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "mx_mail_example_com" {
  zone_id = var.host_zone_id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.ap-northeast-1.amazonses.com"]
}

resource "aws_route53_record" "txt_mail_example_com" {
  zone_id = var.host_zone_id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "txt_dmarc_example_com" {
  zone_id = var.host_zone_id
  name    = "_dmarc.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1;p=quarantine;pct=25;rua=mailto:dmarcreports@${var.domain}"]
}

resource "aws_ses_domain_identity_verification" "main" {
  domain = aws_ses_domain_identity.main.id
}

# TODO もし本番稼働する場合は以下も実施送信制限の解除をリクエスト（オプショナル）
# resource "aws_sesv2_account_details" "main" {
#   mail_type               = "MARKETING"
#   website_url             = "https://XXXXX.com"
#   contact_language        = "EN"
#   use_case_description    = "Sending marketing emails to our users."
#   additional_contact_email_addresses = ["admin@test.com"]
# }