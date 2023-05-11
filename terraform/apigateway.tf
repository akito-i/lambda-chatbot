resource "aws_api_gateway_rest_api" "chatbot" {
  name = "chatbot"
}

# /chatのリクエストを許可する
resource "aws_api_gateway_resource" "chatbot" {
  rest_api_id = aws_api_gateway_rest_api.chatbot.id
  parent_id   = aws_api_gateway_rest_api.chatbot.root_resource_id
  path_part   = "chat"
}

# /chatにPOSTのリクエストを登録する
resource "aws_api_gateway_method" "chatbot" {
  rest_api_id   = aws_api_gateway_rest_api.chatbot.id
  resource_id   = aws_api_gateway_resource.chatbot.id
  http_method   = "POST"
  authorization = "NONE"
}

# apigatewayからのリクエストをlambdaにプロキシする
resource "aws_api_gateway_integration" "chatbot" {
  rest_api_id = aws_api_gateway_rest_api.chatbot.id
  resource_id = aws_api_gateway_resource.chatbot.id
  http_method = aws_api_gateway_method.chatbot.http_method

  type          = "AWS_PROXY"
  integration_http_method = "POST"
  uri           = aws_lambda_function.chatbot.invoke_arn
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  # lambda関数の呼び出しを許可
  action        = "lambda:InvokeFunction"
  # lambda関数の名前を指定する
  function_name = aws_lambda_function.chatbot.function_name
  # apigatewayの識別子(ARN)
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.chatbot.execution_arn}/*/*"
}

# prodにデプロイする
resource "aws_api_gateway_deployment" "chatbot" {
  # デプロイしたいapigatewayに依存させる
  depends_on = [aws_api_gateway_integration.chatbot]

  rest_api_id = aws_api_gateway_rest_api.chatbot.id
  stage_name  = "prod"
}
