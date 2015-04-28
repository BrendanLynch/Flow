from flask import Flask, request, jsonify
from flask.ext.mongoengine import MongoEngine

app = Flask(__name__)
app.debug = True

app.debug = True
app.config["MONGODB_SETTINGS"] = {'DB': "DB_NAME_HERE", "host":'mongodb://user:pass@MONGO_URL_HERE/DB_NAME_HERE'}

db = MongoEngine(app)

@app.route('/')
def hello():
	return 'Flow'

class Flow(db.Document):
    name = db.StringField(required=True)
    status = db.IntField(default=0, required=True)

@app.route('/flow', methods = ['GET'])
def getFlow(status_code=200):
    output = []
    for flow in Flow.objects.order_by('name'):
        output.append({
            "name": flow.name,
            "status": flow.status
        })
    resp = jsonify({"flow":output})
    resp.status_code = status_code
    return resp

@app.route('/flow', methods = ['POST'])
def setFlow():
    flow = Flow(name = request.values['name'],
            status = int(request.values['status']))
    flow.save()
    return getFlow(status_code=201)

@app.route('/flow/<name>', methods = ['PUT'])
def updateFlow(name=None):
    flow = Flow.objects.get(name=name)
    flow.status = int(request.values['status'])
    flow.save()
    return getFlow()
