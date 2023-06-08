import formidable from 'formidable';
import path from "path";
import fs from "fs";

const cloudinary = require('cloudinary').v2;

// Configuration 
cloudinary.config({
    cloud_name: process.env.CLOUD_NAME,
    api_key: process.env.API_KEY,
    api_secret: process.env.API_SECRET
});

export const config = {
    api: {
        bodyParser: false
    }
};


const readFile = (req) => {
    const options = {};
    options.uploadDir = path.join(process.cwd(), "/public/images");
    options.filename = (name, ext, path, form) => {
        return Date.now().toString() + "_" + path.originalFilename;
    };
    const form = formidable(options);
    return new Promise((resolve, reject) => {
        form.parse(req, (err, fields, files) => {
            if (err) reject(err);
            resolve({ fields, files });
        });
    });
};

const handler = async (req, res) => {
    // try {
    //     fs.readdir(path.join(process.cwd() + "/public", "/images"));
    // } catch (error) {
    //     fs.mkdir(path.join(process.cwd() + "/public", "/images"), (err) => {
    //         if (err) {
    //             console.error(err);
    //             res.status(500).json({ error: 'Internal server error' });
    //         }
    //     });
    // }
    const { fields, files } = await readFile(req, true);
    const imageFile = files.image;
    // console.log(imageFile);

    //upload to cloudinary
    const response = await cloudinary.uploader.upload(imageFile.filepath, {
        resource_type: 'image',
        public_id: imageFile.name,
    });
    const videoUrl = response.secure_url;
    res.status(200).json({ "videoUrl": videoUrl });
};

export default handler;


function run_the_weaver(image_path, output_path) {
    const python = spawn('python', ['./test.py', word]);
    // collect data from script
    python.stdout.on('data', function (data) {
        console.log(`RECIEVED ${data.toString()}`);
    });
}