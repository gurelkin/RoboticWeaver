"use client";
import Image from 'next/image'
import styles from './page.module.css'
import { useState } from 'react';
import { ClipLoader } from "react-spinners";
import ReactPlayer from 'react-player'

export default function Home() {
  const [image, setImage] = useState(null);
  const [loading, setLoading] = useState(false);
  const [video, setVideo] = useState(null);

  const submitData = async (e) => {
    console.log("submitting...")
    setLoading(true);
    e.preventDefault();
    const formData = new FormData();
    try {
      formData.append("image", image)
      const response = await fetch(`/api/post`, {
        method: "POST",
        body: formData,
      });
      const data = await response.json()
      setVideo(data.videoUrl);
      setLoading(false);
    } catch (error) {
      setLoading(false);
      console.error(error);
    }
  };

  const handleImageChange = (event) => {
    if (event.target.files && event.target.files[0]) {
      setImage(event.target.files[0]);
    }
  };

  return (
    <main className={styles.main}>
      <div>
        <div className={styles.description}>
          <h1>🤖🎨Automatic Weaver🧵🖼️</h1>
          <p>upload a picture file, and i will transform it into a black and white weaving!</p>
          <p>INSTRUCTIONS:<br />
            1. upload a face image, make sure the face are in the middle of the picture.<br />
            2. the process may take up to 1 minute, please do not refresh the page.<br />
            3. Get a video of your picture being weaved in black and white!
          </p>
        </div>
        <div>
          {loading && (
            <div className="spinner">
              <ClipLoader color="#123abc" loading={loading} classNasme='spinner' size={100} />
              <p>please wait - do not refresh the page...</p>
            </div>

          )}
        </div>
        <div>
          <form onSubmit={submitData}>
            <input type="file" accept="image/*" onChange={handleImageChange} />
            <input className="create" disabled={!image} type="submit" value="Create" />
          </form>
        </div>
        <div>
          {video ? <ReactPlayer url={video} controls={true} /> : <></>}
        </div>
      </div>
      <style jsx>{` 
    form {
      display: flex;
      flex-direction: column;
      align-items: center;
      margin-top: 20px;
    }

    input[type="file"] {
      margin-bottom: 10px;
    }

    .create {
      background-color: grey;
      color: white;
      padding: 10px 20px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }

    .create:disabled {
      background-color: lightgrey;
      cursor: not-allowed;
    }
    /* Component styles */
  .spinner {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    margin-top: 20px;
  }

  .spinner p {
    margin-top: 10px;
    color: grey;
  }
  `}</style>
    </main>
  )
}
