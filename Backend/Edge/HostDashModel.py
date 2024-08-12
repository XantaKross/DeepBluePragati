from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import gc
import google.generativeai as genai


genai.configure(api_key="AIzaSyB5VkiHcv2OhlJvXLjNjNOQE6tsWbMaYHI")
model = genai.GenerativeModel('gemini-pro')


# Define a custom HTTP request handler
class RequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        # Get the length of the incoming data
        content_length = int(self.headers['Content-Length'])

        post_data = self.rfile.read(content_length)


        # Create pages list from given string.
        received_pages = post_data.decode('utf-8').strip().split("+")

        contexts = "\n\n".join(received_pages)

        query_beta = f"""Depending on the most important data from given context, generate 20 Question and Answer pairs. Keep them updated and close to 2024.
        Format required --> [
        QUESTION: ...
        ANSWER: ...  
        
        QUESTION: ...
        ANSWER: ...
        ];
        Kindly adhere to the format and create very important questions from contexts given below. CRITICAL WARNING: DO NOT CHANGE THE FORMAT UNDER ANY CIRCUMSTANCE.
        CONTEXT: {contexts}
        """


        generated = model.generate_content(query_beta).text

        pairs = [line.split(":")[1].strip() for line in generated.splitlines() if
                 "QUESTION" in line or "ANSWER" in line]
        result = {pairs[i]: pairs[i + 1] for i in range(0, len(pairs), 2)}

        # Send the response
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        # Convert the response dictionary to a JSON string
        response_data_str = json.dumps(result)
        # Convert the string to bytes and send it as the response body
        self.wfile.write(response_data_str.encode('utf-8'))




# Define the host and port
host = 'localhost'
port = 1802

# Create an instance of the HTTPServer class
server = HTTPServer((host, port), RequestHandler)

def closeServer(model):
    print("Closing DASH Server...")

    del model
    gc.collect()

# Start the server
print(f"DASH Gemini running on {host}:{port}")
try: server.serve_forever()
except KeyboardInterrupt:
    # Run the specific function before quitting
    closeServer(model)
