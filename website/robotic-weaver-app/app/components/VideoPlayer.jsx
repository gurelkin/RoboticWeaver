import ReactPlayer from 'react-player'

const VideoPlayer = (props) => {
    return (
        <ReactPlayer url={props.url} controls={true} />
    );
}

export default VideoPlayer;