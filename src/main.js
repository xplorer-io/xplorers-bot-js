
exports.lambda_handler = async function (event, context) {
    const request = JSON.stringify(event)
    console.log("EVENT IS: \n" + request)

    // Parse the slack request body
    const requestBody = JSON.parse(event.body)

    if ("challenge" in requestBody)
    {
        return requestBody.challenge
    }
    console.log("No challenge token found, moving on!")
}
