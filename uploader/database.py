from pymongo import MongoClient
import gridfs
import os

client = MongoClient("mongodb://mongodb-external-service.default.svc.cluster.local:27017/")

# connection_string = os.environ.get("MONGO_CONNECTION_URI")
# client = MongoClient(connection_string)


db = client.exercise_files
fs =gridfs.GridFS(db)


