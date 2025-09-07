#!/bin/bash

# Starting the streamlit application 
uv run streamlit run frontend.py &

# Starting FastAPI server
uv run fastapi run routes.py &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?