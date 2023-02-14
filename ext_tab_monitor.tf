resource "aws_iam_role" "ext_tab_monitor" {
  name = "${var.ext_tab_monitor_name}-${var.namespace}-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF


  tags = {
    Name = "iam-${var.ext_tab_monitor_name}-${var.naming_suffix}"
  }
}

resource "aws_iam_role_policy" "ext_tab_monitor_policy" {
  name = "${var.ext_tab_monitor_name}-${var.namespace}-lambda-policy"
  role = aws_iam_role.ext_tab_monitor.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.ext_tab_input_bucket}-${var.namespace}",
        "arn:aws:s3:::${var.ext_tab_input_bucket}-${var.namespace}/*"]
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": "${var.kms_key_s3}"
    },
    {
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/slack_notification_webhook"
    }
  ]
}
EOF

}

data "archive_file" "ext_tab_monitor_zip" {
  type        = "zip"
  source_dir  = "${local.path_module}/lambda/tab_monitor/code"
  output_path = "${local.path_module}/lambda/tab_monitor/package/ext_tab_lambda.zip"
}

resource "aws_lambda_function" "ext_tab_monitor" {
  filename         = "${path.module}/lambda/tab_monitor/package/ext_tab_lambda.zip"
  function_name    = "${var.ext_tab_monitor_name}-${var.namespace}-lambda"
  role             = aws_iam_role.ext_tab_monitor.arn
  handler          = "function.lambda_handler"
  source_code_hash = data.archive_file.ext_tab_monitor_zip.output_base64sha256
  runtime          = "python3.7"
  timeout          = "900"
  memory_size      = "2048"

  environment {
    variables = {
      bucket_name    = "${var.ext_tab_input_bucket}-${var.namespace}"
      threshold_min = var.ext_tab_monitor_lambda_run
      path_ext_tab   = var.output_path_ext_tab
    }
  }

  tags = {
    Name = "lambda-${var.ext_tab_monitor_name}-${var.naming_suffix}"
  }

  # lifecycle {
  #   ignore_changes = [
  #     filename,
  #     last_modified,
  #     source_code_hash,
  #   ]
  # }

}

resource "aws_cloudwatch_log_group" "ext_tab_monitor" {
  name              = "/aws/lambda/${aws_lambda_function.ext_tab_monitor.function_name}"
  retention_in_days = 90

  tags = {
    Name = "log-lambda-${var.ext_tab_monitor_name}-${var.naming_suffix}"
  }
}

resource "aws_iam_policy" "ext_tab_monitor_logging" {
  name        = "${var.ext_tab_monitor_name}-${var.namespace}-lambda-logging"
  path        = "/"
  description = "IAM policy for monitor lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.ext_tab_monitor.arn}",
        "${aws_cloudwatch_log_group.ext_tab_monitor.arn}/*"
      ],
      "Effect": "Allow"
    },
    {
       "Action": "logs:CreateLogGroup",
       "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
       "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "ext_tab_monitor_logs" {
  role       = aws_iam_role.ext_tab_monitor.name
  policy_arn = aws_iam_policy.ext_tab_monitor_logging.arn
}

resource "aws_cloudwatch_event_rule" "ext_tab_monitor" {
  name                = "${var.ext_tab_monitor_name}-${var.namespace}-cw-event-rule"
  description         = "Fires 1pm Mon - Fri"
  schedule_expression = "cron(0 13 ? * MON-FRI *)"
  is_enabled          = "true"
}

resource "aws_cloudwatch_event_target" "ext_tab_monitor" {
  rule = aws_cloudwatch_event_rule.ext_tab_monitor.name
  arn  = aws_lambda_function.ext_tab_monitor.arn
}

resource "aws_lambda_permission" "ext_tab_monitor_cw_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ext_tab_monitor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ext_tab_monitor.arn
}
