import json

def lambda_handler(event, context):
    # モックレスポンス
    return {
        'statusCode': 200,
        'body': json.dumps({
            'id': 1,
            'name': 'pochi'
        })
    }
