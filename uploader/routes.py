from typing import Annotated

from fastapi import FastAPI, File, UploadFile
from pydantic import BaseModel
from database import fs

app = FastAPI()



@app.post("/uploadfiles/")
async def create_upload_files(files: list[UploadFile] = File(...)):
    # create the logic to  ensure that the files got loaded to mongodb    
    
    for file in files:
        # Checking for duplicate files
        
        # sending files up to 
        fs.put(file.file)    
        
        
    return {"documents":[file.filename for file in files]}
    

@app.get("/")
async def read_root():
    return {"message": "File Upload API server is running"}







#mongo ip: 172.17.0.2:27017