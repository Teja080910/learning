const Props = (props) => {
    return (
        <div>
            <h1>Props Example</h1>
            <p>This is a simple component that accepts props.</p>
            <p>Name: {props.name}</p>
            <p>Age: {props.age}</p>
            <p>City: {props.city}</p>
        </div>
    );
};

export default Props;