import formidable from 'formidable';
import path from "path";
import fs from "fs";

export const config = {
    api: {
        bodyParser: false,
    },
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
    console.log(imageFile);
    // TODO: make image page and useRouter to get there


    res.json({ done: "ok" });
};

export default handler;
