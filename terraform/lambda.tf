data "archive_file" "operational_triage" {
  type        = "zip"
  source_file = "${path.module}/../lambda/operational_triage/handler.py"
  output_path = "${path.module}/operational-triage.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "operational_triage_lambda" {
  name               = "${local.name_prefix}-operational-triage-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Name    = "${local.name_prefix}-operational-triage-role"
    Purpose = "OperationalIncidentTriage"
  }
}

resource "aws_iam_role_policy_attachment" "operational_triage_basic_execution" {
  role       = aws_iam_role.operational_triage_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "operational_triage_permissions" {
  statement {
    sid    = "TagCloudGuardInstances"
    effect = "Allow"

    actions = [
      "ec2:CreateTags"
    ]

    resources = [
      aws_instance.dev.arn,
      aws_instance.prod.arn
    ]
  }
}

resource "aws_iam_role_policy" "operational_triage_permissions" {
  name   = "${local.name_prefix}-operational-triage-permissions"
  role   = aws_iam_role.operational_triage_lambda.id
  policy = data.aws_iam_policy_document.operational_triage_permissions.json
}

resource "aws_lambda_function" "operational_triage" {
  function_name = "${local.name_prefix}-operational-triage"
  description   = "Classifies CloudWatch incidents and tags affected EC2 instances."

  filename         = data.archive_file.operational_triage.output_path
  source_code_hash = data.archive_file.operational_triage.output_base64sha256

  role    = aws_iam_role.operational_triage_lambda.arn
  handler = "handler.lambda_handler"
  runtime = "python3.12"

  architectures = ["x86_64"]
  timeout       = 15
  memory_size   = 128

  environment {
    variables = {
      PROJECT_NAME = var.project_name
    }
  }

  tags = {
    Name    = "${local.name_prefix}-operational-triage"
    Purpose = "OperationalIncidentTriage"
  }
}

resource "aws_lambda_permission" "allow_operational_sns" {
  statement_id  = "AllowExecutionFromOperationalSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.operational_triage.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.operational_alerts.arn
}

resource "aws_sns_topic_subscription" "operational_triage_lambda" {
  topic_arn = aws_sns_topic.operational_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.operational_triage.arn

  depends_on = [
    aws_lambda_permission.allow_operational_sns
  ]
}