## Getting Started

This is Pragati an Android application me and my teammates developed for Deep Blue Season 8.

It contains:
1. A robust and beautiful frontend meticulously design by my team.
4. Django backend with MySQL for user authentication and handling large file uploads (1 GB PDFs processed in 10 sec).
5. "View PDF" page by Ravikumar M for in-app PDF viewing.
6. "Dashboard" page by Akshay B for generating top 20 probable FAQs from uploaded files.
7. A Flutter-based file handler I designed for managing multiple file uploads and deletions.
8. Option to connect with Google Gemini  as an alternative AI chatbot (Heartful thanks to Google for their free API. It was very helpful back then.)
9. A fully fleshed out API connecting the Flutter frontend and Django backend.

NOTE: the AI folder from Edge is missing in this repo. You may find it at https://huggingface.co/XantaK/Gyan/tree/main
Download the folder along with its files and place it underneath Pragati->Backend->Edge and then properly initialize the projects requirements and run the server.

MAIN REQUIREMENTS:
-> Python 12
-> PyTorch CUDA
-> Flutter
-> Django
