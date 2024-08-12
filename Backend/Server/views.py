from django.http import JsonResponse, HttpResponse
from django.middleware.csrf import get_token
import json, base64
from django.views.decorators.csrf import ensure_csrf_cookie
import requests
from Core.Common import Contexter, delete_file
from databaseAPI.models import CustomUser
from django.contrib.auth import authenticate, login, logout
import os
import re

model_url = "http://localhost:1800"
gemini_url = "http://localhost:1801"
dash_url = "http://localhost:1802"
path = "C:/Users/Shahjahan/AndroidStudioProjects/Pragati/Backend/databaseAPI/Users/" #r"C:\Users\Shahjahan\AndroidStudioProjects\Pragati\Backend\DB\UserData\tempFile.pdf"
contexter = Contexter()


full_path = ""

def DashAPI(request):
    importance = {}
    def remove_inbetween(string): return "".join([i for i in string if i.isdigit()])

    for i, page in enumerate(contexter.raw_pages):
        count_numbers = sum([1 for i in page if i.isdigit()])
        sum_size_numbers = sum([len(remove_inbetween(w)) for w in page.split()])
        symbol_counts =  sum([1 for i in page if i in ["%", "+", "$", "₹"]])

        importance[i] = count_numbers*(1/4) + sum_size_numbers*(1/4) + symbol_counts*(1/2)

    sorted_pages = sorted(importance.keys(), key=lambda x: importance[x],
                          reverse=True)
    selected_pages = "+".join([contexter.raw_pages[i] for i in sorted_pages[:10]])

    result = json.loads(requests.post(dash_url, selected_pages).content)
    # but what is the result?


    return JsonResponse(result)



# Send a file from server to App.
def GetLatestAPI(request):
    json_dict = json.loads(request.body)
    # # Get file name.
    # json_dict["fileName"]

    # Get all available files.
    files = [file for file in os.listdir(full_path)]

    if files == []:
        data = {"46": 46}
    else:
        with open(full_path + "/" + json_dict["currentMain"], "rb") as file:
            data = {"file" : str(base64.b64encode(file.read()).decode("utf-8"))}

    print(data["file"][:5], data["file"][-5:])

    return JsonResponse(data)


def ReaderAPI(request):
    # This will be called whenever
    # 1. A new document is uploaded.
    # 2. A new document is selected.

    global full_path
    json_dict = json.loads(request.body)

    final_path = full_path + "/" + json_dict["currentMain"]

    if os.path.exists(final_path): # read the document if it exists. Otherwise unnecessary.
        contexter.read_file(final_path)

    return JsonResponse({ "46" : 46})



@ensure_csrf_cookie
def FileAPI(request):
    global full_path

    if request.method == "GET":
        data={"csrftoken" : get_token(request)}

    else:
        print(1351)
        # Now that we have got the file as an json encoded object
        # we must next save the file in a appropriate folder.
        json_dict = json.loads(request.body)


        if json_dict["mode"] == "Delete":
            #Delete current file.
            final_path = full_path + json_dict["fileName"]
            delete_file(final_path)

            file_list = [file for file in os.listdir(full_path)]

            if file_list!=[]: # if filelist is not empty.
                data = {"userFiles": file_list}
                final_path = full_path + "/" + file_list[0]
                contexter.read_file(final_path)

            data = {46: '46'} # no earlier data exists.

        elif json_dict["mode"] == "Recieve":
            # Send latest file as bytes object.
            file_list = [file for file in os.listdir(full_path)]

            if file_list!=[]: # if filelist is not empty.
                data = {"userFiles": file_list}
                final_path = full_path + "/" + file_list[0]

                if not contexter.read: contexter.read_file(final_path)


            else:
                data = {"46" : 46} # no earlier data exists.

        elif json_dict["mode"] == "Send":
            file = json_dict["file"] # get the data of file.
            decoded_file = base64.b64decode(file)

            final_path = full_path + "/" + json_dict["fileName"]

            # Create the folder if it doesn't exist using os.makedirs() with exist_ok=True
            os.makedirs(os.path.dirname(final_path), exist_ok=True)

            # Save the file in a specific location.
            with open(final_path, "wb+") as tempFile: tempFile.write(decoded_file)

            if not contexter.read: contexter.read_file(final_path)

            print("File saved.")
            data = {"23": 23}

    return JsonResponse(data)

def TextAPI(request):
    # POST method. Reply to each query with respect to the given document.
    # 1. Query.
    # 2. Collection.

    # Can use 1 out of 2 total models now.
    request_data = json.loads(request.body)
    query = request_data["text"]

    context = contexter.get_context(query)

    url = model_url if request_data["model"] == True else gemini_url

    print(contexter.read, len(context.split("\n")))
    api_text = f"query={query}|context={context}\n............." # the star is end of text token.

    # Contact with locally hosted model API and get text.
    result = json.loads(requests.post(url, api_text).content) # Only get the AI's part from the text. Ignore everything else.

    print(result)

    content = {"context": context, "aiMsg": result["received"], "page_no" : 10}#page_no}
    response = JsonResponse(content, status=299)

    return response



def LogSignIn(request):
    global full_path

    if request.method == "GET":
        return JsonResponse({"csrf": get_token(request)}, status=299)
    else:
        json_dict = json.loads(request.body)
        if json_dict["mode"] == "login":
            try:
                user = authenticate(email=json_dict["mail"], password=json_dict["password"])

                if user.is_authenticated != None:
                    folder = json_dict["mail"].split("@")[0] + '/'
                    full_path = path + folder

                    login(request, user)
                return JsonResponse({"confirmation": True})
            except Exception as e:
                print(23, e)
                return JsonResponse({"confirmation": False})


        elif json_dict["mode"] == "signin":
            email, password = json_dict["mail"], json_dict["password"]

            pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

            try:
                if re.match(pattern, email):
                    CustomUser.objects.create_user(email, password) # create user in db
                    folder = json_dict["mail"].split("@")[0] #+ '/' + "tempfile.pdf"
                    full_path = path + folder

                    # Create user space.
                    if not os.path.exists(full_path): os.makedirs(full_path)


                    return JsonResponse({"confirmation": True})
                else:
                    raise Exception("Invalid Email ID")
            except Exception as e:
                print(43, e)
                return JsonResponse({"confirmation": False})
