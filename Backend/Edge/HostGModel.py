from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import gc
import google.generativeai as genai


genai.configure(api_key="AIzaSyClTc8siuNribUvnJm5FoFetoRqDoL2-eI")

model = genai.GenerativeModel('gemini-pro')

def create_dict_from_string(input_string): return {item[0] : item[1] for item in [i.split("=") for i in input_string.split("|")] if len(item) == 2}
# Two keys, docs and query.


# Define a custom HTTP request handler
class RequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        # Get the length of the incoming data
        content_length = int(self.headers['Content-Length'])

        # Adding 7 breaks things up.
        post_data = self.rfile.read(content_length)

        # Convert the incoming data from bytes to a string
        # IP Format: {"context": <context>, "userMsg": <message>}
        received_data = create_dict_from_string(post_data.decode('utf-8').strip())
        context = f"CONTEXT: {received_data['context']}\n"

        print("\n\n\n")
        print("-"*100)
        print(context)
        print("-"*100)
        print("\n\n\n")

        prompt_template=f'QUESTION: {received_data["query"]}\nANSWER:'

        output = (model.generate_content(context + prompt_template)).text # model.run(context, prompt_template).split("ANSWER:")
        result = output

        # OP Format: {"context": <context>, "aiMsg": <message>, "page_no" : <page_no>}
        response_data = {"received": result}

        # Send the response
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        # Convert the response dictionary to a JSON string
        response_data_str = json.dumps(response_data)
        # Convert the string to bytes and send it as the response body
        self.wfile.write(response_data_str.encode('utf-8'))




# Define the host and port
host = 'localhost'
port = 1801

# Create an instance of the HTTPServer class
server = HTTPServer((host, port), RequestHandler)

def closeServer(model):
    print("Closing Gemini Server...")

    del model
    gc.collect()

# Start the server
print(f"Gemini Server running on {host}:{port}")
try: server.serve_forever()
except KeyboardInterrupt:
    # Run the specific function before quitting
    closeServer(model)
