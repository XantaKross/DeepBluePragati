from AI.ProductionModel import AI
import torch
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import gc

model = AI()

def create_dict_from_string(input_string): return {item[0] : item[1] for item in [i.split("=") for i in input_string.split("|")]}

def replace_(string, list_):
    for i in list_: string = string.replace(i, '')
    return string

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

        #outputs = [] # Create a list of all outputs.

        print("START---", received_data['context'], "---END")

        context = f"CONTEXT: {received_data['context']}"

        print("\n\n\n")
        print("-"*100)
        print(context)
        print("-"*100)
        print("\n\n\n")

        prompt_template=f'QUESTION: {received_data["query"]}\n ANSWER:'

        output = model.run(context, prompt_template).split("ANSWER:")
        output = list(map(str.strip, output))

        replace_list = ["QUESTION:", "EXAMPLE:", "NOTE:"]
        result = replace_(output[1].strip(), replace_list)


        if received_data['context'] == '' or result == '':
            result = "Data not found in document."



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
port = 1800

# Create an instance of the HTTPServer class
server = HTTPServer((host, port), RequestHandler)

def closeServer(model):
    print("Closing Server...")

    del model
    torch.cuda.empty_cache()
    gc.collect()

# Start the server
print(f"Server running on {host}:{port}")
try: server.serve_forever()
except KeyboardInterrupt:
    # Run the specific function before quitting
    closeServer(model)
