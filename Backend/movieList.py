from flask import Flask
from flask import jsonify
from flask import request
from flask_pymongo import PyMongo
import os
import re
import copy
import string
from nltk.corpus import stopwords 
from nltk.tokenize import word_tokenize

def ranking(lst, searched):
    lst2= copy.deepcopy(lst)

    for u in lst2:
        if searched == u['title'].lower():
            u['rank'] = u['rank'] + 1000
        elif searched in u['title'].lower():
            u['rank'] = u['rank'] + 900

        if searched == u['description'].lower():
            u['rank'] = u['rank'] + 600
        elif searched in u['description'].lower():
            u['rank'] = u['rank'] + 585

        if searched == u['duration'].lower():
            u['rank'] = u['rank'] + 300
        elif searched in u['duration'].lower():
            u['rank'] = u['rank'] + 260

        if searched == u['year']:
            u['rank'] = u['rank'] + 195
        elif searched in u['year']:
            u['rank'] = u['rank'] + 150

        if searched == u['rating']:
            u['rank'] = u['rank'] + 195
        elif searched in u['rating']:
            u['rank'] = u['rank'] + 150

        if searched == u['id']:
            u['rank'] = u['rank'] + 1000
        elif searched in u['id']:
            u['rank'] = u['rank'] + 900
    
    rank1 = sorted(lst2, key = lambda i : (i['rank'],i['rating']), reverse = True)
    return rank1


app = Flask(__name__)

app.config['MONGO_DBNAME'] = 'restdb'

app.config['MONGO_URI'] = 'mongodb+srv://RV:securePass@cluster0.kalzo.gcp.mongodb.net/DevSprint2'
                           
mongo = PyMongo(app)

@app.route('/')
def index():
    return 'This is home page request area'

@app.route('/get_data', methods = ['GET'])
def get_data():
    try:
        rdata = mongo.db.resList
        output = []
        for s in rdata.find():
            output.append({'title' : s['title'], 'description' : s['description'], 'duration':s['duration'], 'year':s['year'], 'rating':s['rating'],'id':s['id'], 'imageUrl': s['imageUrl'] })
        return jsonify(sorted(output, key = lambda i: i['rating'],reverse=True))
    except:
        return jsonify([{'title' : "Yet to find the movie", 'description' : "No data available", 'duration':"NA", 'year':"NA", 'rating':"NA",'id':"NA",'imageUrl': 'https://image.shutterstock.com/image-vector/not-available-grunge-rubber-stamp-260nw-549465931.jpg' }])


@app.route('/search_data/<data>', methods = ['GET'])
def search_data(data):
    try:
        rdata = mongo.db.resList
        output = []
        search = data
        search = re.sub(r"^\s+|\s+$", "", search)
        search = search.lower()
        REGX = re.compile(f".*{search}.*", re.I)
        search_request = {
            '$or': [
                {'title':{'$regex': REGX}},
                {'description':{'$regex': REGX}},
                {'duration':{'$regex': REGX}},
                {'year':{'$regex': REGX}},
                {'rating':{'$regex': REGX}},
                {'id':{'$regex': REGX}},
            ]
        }
        s= rdata.find(search_request)
        if s:
            for j in s:
                output.append({'title' : j['title'], 'description' : j['description'], 'duration':j['duration'], 'year':j['year'], 'rating':j['rating'],'id':j['id'], 'imageUrl': j['imageUrl'], 'rank':100 })
        ls = ranking(output, search)

        stop_words = stopwords.words('english')
        stop_words.extend([',','.',';']) 
        words = search.split()

        filtered_sentence = [w for w in words if not w in stop_words]
        for k in filtered_sentence:
            REGX = re.compile(f".*{k}.*", re.I)
            search_request = {
            '$or': [
                {'title':{'$regex': REGX}},
                {'description':{'$regex': REGX}},
                {'duration':{'$regex': REGX}},
                {'year':{'$regex': REGX}},
                {'rating':{'$regex': REGX}},
                {'id':{'$regex': REGX}},
                ]
            }

            s= rdata.find(search_request)

            for j in s:
                if list(filter(lambda item : item['title'] == j['title'], ls)):
                    ind = next((i for i, item in enumerate(ls) if item['title'] == j['title']), None)
                    ls[ind]['rank'] = ls[ind]['rank'] + 100
                else:
                    ls.append({'title' : j['title'], 'description' : j['description'], 'duration':j['duration'], 'year':j['year'], 'rating':j['rating'],'id':j['id'], 'imageUrl': j['imageUrl'], 'rank':0 })
        
            ls = ranking(ls,k)
        if len(ls)==0:
            return jsonify([{'title' : "Yet to find the movie", 'description' : "No data available", 'duration':"NA", 'year':"NA", 'rating':"NA",'id':"NA",'imageUrl': 'https://image.shutterstock.com/image-vector/not-available-grunge-rubber-stamp-260nw-549465931.jpg' }])
        return jsonify(ls)
    except:
        return jsonify([{'title' : "Yet to find the movie", 'description' : "No data available", 'duration':"NA", 'year':"NA", 'rating':"NA",'id':"NA",'imageUrl': 'https://image.shutterstock.com/image-vector/not-available-grunge-rubber-stamp-260nw-549465931.jpg' }])

if __name__ == '__main__':
    port1 = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0' , port=port1)