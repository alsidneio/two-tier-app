from pymongo import MongoClient
import gridfs


client = MongoClient("mongodb://172.17.0.2:27017/")

db = client.exercise_files
fs =gridfs.GridFS(db)


