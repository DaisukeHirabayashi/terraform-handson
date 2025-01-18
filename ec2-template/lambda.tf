resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy_attach" {
  name       = "lambda_policy_attach"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "my_lambda_function" {
  function_name = "MyLambdaFunction"
  handler       = "lambda_function.lambda_handler"  # ファイル名を 'lambda_function.py' と仮定
  runtime       = "python3.8"  # 使用するPythonのバージョンを選択
  role          = aws_iam_role.lambda_role.arn

  source_code_hash = filebase64sha256("lambda_function.zip")  # zipファイルを指定
  filename        = "lambda_function.zip"  # zipファイルのパス
}
