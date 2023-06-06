"use client";
import Image from 'next/image'
import styles from './page.module.css'
import { useState } from 'react';
import { ClipLoader } from "react-spinners";

export default function Home() {
  const [image, setImage] = useState(null);
  const [loading, setLoading] = useState(false);

  const submitData = async (e) => {
    console.log("submitting...")
    setLoading(true);
    e.preventDefault();
    const formData = new FormData();
    try {
      formData.append("image", image)
      await fetch(`/api/post`, {
        method: "POST",
        body: formData,
      });
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
        </div>
        <div>
          {loading && (
            <div className="spinner">
              <ClipLoader color="#123abc" loading={loading} className='spinner' size={100} />
            </div>
          )}
        </div>
        {/* <div>
          {image ? <img src={image} alt="" /> : <></>}
        </div> */}
        <div>
          <form onSubmit={submitData}>
            <input type="file" accept="image/*" onChange={handleImageChange} />
            <input className="create" disabled={!image} type="submit" value="Create" />
          </form>
        </div>


      </div>
    </main>
  )
}
