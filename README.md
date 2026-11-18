# NCERT Bio Tutor — Render deployment source

This public repository contains only the Dockerfile and pinned Python
requirements used by Render. The application code and the pre-built 706-chunk
Chroma index are downloaded during the Docker build from the public bundle at:

`https://huggingface.co/datasets/Soumojit444/ncert-bio-tutor-deploy`

No API keys or PDFs are stored here.
