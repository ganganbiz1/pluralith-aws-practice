resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${var.security_group_alb_id}"]
  subnets            = ["${var.subnet_public_1a_id}", "${var.subnet_public_1c_id}"]

  enable_deletion_protection = false

# アクセスログの設定は後回し
#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "test-lb"
#     enabled = true
#   }
}

resource "aws_lb_target_group" "main" {
  name     = "${var.environment}-ecs-tg"
  port     = 9000
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  target_type = "ip"
  health_check {
      port = 9000
      path = "/healthcheck"
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.cert_lb_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = aws_lb_listener.main.arn

  # 受け取ったトラフィックをターゲットグループへ受け渡す
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.id
  }

  # ターゲットグループへ受け渡すトラフィックの条件
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
