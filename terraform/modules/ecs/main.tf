resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-cluster"
}


resource "aws_ecs_task_definition" "main" {
  family = "${var.environment}-task"

  requires_compatibilities = ["FARGATE"]

  # ECSタスクが使用可能なリソースの上限
  # タスク内のコンテナはこの上限内に使用するリソースを収める必要があり、メモリが上限に達した場合OOM Killer にタスクがキルされる
  cpu    = "256"
  memory = "512"

  # ECSタスクのネットワークドライバ
  # Fargateを使用する場合は"awsvpc"決め打ち
  network_mode = "awsvpc"

  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn = var.ecs_execution_role_arn

  # 起動するコンテナの定義
  container_definitions = file("./../../${var.environment}/container_definitions/container_definitions.json")
}

resource "aws_ecs_service" "main" {
  name = "${var.environment}-service"

  cluster = aws_ecs_cluster.main.id

  launch_type = "FARGATE"

  # ECSタスクの起動数を定義
  desired_count = "1"

  # 起動するECSタスクのタスク定義
  task_definition = aws_ecs_task_definition.main.arn

  # ECSタスクへ設定するネットワークの設定
  network_configuration  {
    # タスクの起動を許可するサブネット
    subnets         = [var.subnet_private_1a_id, var.subnet_private_1c_id]
    # タスクに紐付けるセキュリティグループ
    security_groups = [var.security_group_ecs_id]
  }

  # ECSタスクの起動後に紐付けるELBターゲットグループ
  load_balancer  {
    target_group_arn = var.aws_lb_target_group_arn
    container_name   = "${var.environment}-api"
    container_port   = 9000
  }
}