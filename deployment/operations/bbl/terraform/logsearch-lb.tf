# Load Balancer
resource "aws_lb" "logsearch_lb" {
  name               = "${var.short_env_id}-logsearch-lb"
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.lb_subnets.*.id}"]
}

# Listener for Kibana
resource "aws_lb_listener" "logsearch_lb_80" {
  load_balancer_arn = "${aws_lb.logsearch_lb.arn}"
  protocol          = "TCP"
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logsearch_lb_80.arn}"
  }
}

resource "aws_lb_target_group" "logsearch_lb_80" {
  name     = "logsearch80"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${local.vpc_id}"

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 30
    protocol            = "TCP"
  }
}

# Listener for Cluster Monitor
resource "aws_lb_listener" "logsearch_lb_8080" {
  load_balancer_arn = "${aws_lb.logsearch_lb.arn}"
  protocol          = "TCP"
  port              = 8080

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logsearch_lb_8080.arn}"
  }
}

resource "aws_lb_target_group" "logsearch_lb_8080" {
  name     = "logsearch8080"
  port     = 8080
  protocol = "TCP"
  vpc_id   = "${local.vpc_id}"

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 30
    protocol            = "TCP"
  }
}

# Listener for Ingestor
resource "aws_lb_listener" "logsearch_lb_5514" {
  load_balancer_arn = "${aws_lb.logsearch_lb.arn}"
  protocol          = "TCP"
  port              = 5514

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logsearch_lb_5514.arn}"
  }
}

resource "aws_lb_target_group" "logsearch_lb_5514" {
  name     = "logsearch5514"
  port     = 5514
  protocol = "TCP"
  vpc_id   = "${local.vpc_id}"

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 30
    protocol            = "TCP"
  }
}

# Listener for Ingestor TLS
resource "aws_lb_listener" "logsearch_lb_6514" {
  load_balancer_arn = "${aws_lb.logsearch_lb.arn}"
  protocol          = "TCP"
  port              = 6514

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logsearch_lb_6514.arn}"
  }
}

resource "aws_lb_target_group" "logsearch_lb_6514" {
  name     = "logsearch6514"
  port     = 6514
  protocol = "TCP"
  vpc_id   = "${local.vpc_id}"

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 30
    protocol            = "TCP"
  }
}

# Listener for RELP
resource "aws_lb_listener" "logsearch_lb_2514" {
  load_balancer_arn = "${aws_lb.logsearch_lb.arn}"
  protocol          = "TCP"
  port              = 2514

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logsearch_lb_2514.arn}"
  }
}

resource "aws_lb_target_group" "logsearch_lb_2514" {
  name     = "logsearch2514"
  port     = 2514
  protocol = "TCP"
  vpc_id   = "${local.vpc_id}"

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 30
    protocol            = "TCP"
  }
}

# Security group
resource "aws_security_group" "logsearch_lb_security_group" {
  name        = "logsearch-lb-security-group"
  description = "Logsearch"
  vpc_id      = "${local.vpc_id}"

  tags {
    Name = "${var.env_id}-logsearch-lb-internal-security-group"
  }

  lifecycle {
    ignore_changes = ["name"]
  }
}

# Security rules
resource "aws_security_group_rule" "logsearch_lb_80" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.logsearch_lb_security_group.id}"
}

resource "aws_security_group_rule" "logsearch_lb_8080" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 8080
  to_port     = 8080
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.logsearch_lb_security_group.id}"
}

resource "aws_security_group_rule" "logsearch_lb_5514" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 5514
  to_port     = 5514
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.logsearch_lb_security_group.id}"
}

resource "aws_security_group_rule" "logsearch_lb_6514" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 6514
  to_port     = 6514
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.logsearch_lb_security_group.id}"
}

resource "aws_security_group_rule" "logsearch_lb_2514" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 2514
  to_port     = 2514
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.logsearch_lb_security_group.id}"
}
