from utilities import goFetch as fetch

def lambda_handler(event, context):
    print("Received event: " + str(event))
    url = event['url']
    print(f"Fetching data from URL: {url}")
    data = fetch(url)
    print(f"Data fetched: {data}")
    return {
        'statusCode': 200,
        'body': data
    }