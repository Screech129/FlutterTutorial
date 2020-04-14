const functions = require('firebase-functions');
const cors = require('cors')({ origin: true });
const Busboy = require('busboy');
const os = require('os');
const path = require('path');
const fs = require('fs');
const fbAdmin = require('firebase-admin');
const { v4: uuidv4 } = require('uuid');

// Imports the Google Cloud client library
const { Storage } = require('@google-cloud/storage');


const gcconfig = {
    projectId: 'fluttertutorialds',
    keyFilename: 'flutterProducts.json'
}
// Creates a client
const storage = new Storage(gcconfig);
// Creates a client from a Google service account key.
// const storage = new Storage({keyFilename: "key.json"});

fbAdmin.initializeApp({
    credential: fbAdmin.credential.cert(require('./flutterProducts.json'))
});


exports.storeImage = functions.https.onRequest((request, response) => {
    return cors(request, response, () => {
        if (request.method !== 'POST') {
            return response.status(500).json({ message: 'Not Allowed.' });
        }
        if (!request.headers.authorization
            || !request.headers.authorization.startsWith('Bearer ')) {
            return response.status(401).json({ error: 'Unauthorized' });
        }

        let idToken;
        idToken = request.headers.authorization.split('Bearer ')[1];
        const busboy = new Busboy({ headers: request.headers });
        let uploadData;
        let oldImagePath;
        busboy.on('file', (fieldname, file, filename, encoding, mimetype) => {
            try {
                const filePath = path.join(os.tmpdir(), filename);
                uploadData = { filepath: filePath, type: mimetype, name: filename };
                file.pipe(fs.createWriteStream(filePath));
            } catch (error) {
                print(error);
            }

        });

        busboy.on('field', (filedname, value) => {
            oldImagePath = decodeURI(value);
        });

        busboy.on('finish', () => {
            try {
                const bucket = storage.bucket('fluttertutorialds.appspot.com');
                const id = uuidv4();
                let imagePath = 'images/' + id + '_' + uploadData.name;
                if (oldImagePath) {
                    imagePath = oldImagePath;
                } 
            } catch (error) {
                print(error);
            }
          

            return fbAdmin.auth().verifyIdToken(idToken).then(decodedToken => {
                return bucket.upload(uploadData.filePath, {
                    uploadType: 'media',
                    destination: imagePath,
                    metadata: {
                        metadata: {
                            contentType: uploadData.type,
                            firebaseStorageDownloadToken: id
                        }
                    }
                }).then(() => {
                    return response.status(201).json({
                        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/'
                            + bucket.name
                            + '/o/'
                            + encodeURIComponent(imagePath)
                            + '?alt=media&token='
                            + id,
                        imagePath: imagePath
                    });
                });
            }).catch(error => {
                return response.status(500).json({ error: error })
            });
        });
        return busboy.end(request.rawBody);
    });
});
