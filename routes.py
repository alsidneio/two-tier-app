from typing import Annotated

from fastapi import FastAPI, File, UploadFile
from pydantic import BaseModel


app = FastAPI()



@app.post("/uploadfiles/")
async def create_upload_files(files: list[UploadFile] = File(...)):
    # create the logic to  ensure that the files got loaded to mongodb
    
    return {"filenames": [file.filename for file in files]}
    

@app.get("/")
async def read_root():
    return {"message": "File Upload API server is running"}
