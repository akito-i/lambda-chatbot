package main

import (
	"math/rand"
	"time"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

var responses = []string{
	"こんにちは！",
	"ご質問があればお気軽にどうぞ。",
	"いい天気ですね。",
	"何かお困りのことがありますか？",
}

func handler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	rand.Seed(time.Now().Unix())
	response := responses[rand.Intn(len(responses))]

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       response,
	}, nil
}

func main() {
	lambda.Start(handler)
}
