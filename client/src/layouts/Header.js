import BookImage from "../assets/placeholder.png";

function Header({image, book_url}) {
  console.log(`image is ${image} and book_url is ${book_url}`)
    return (
        <div className="header">
        <div className="logo">
          <a href={book_url}>
            <img
              src={image ? image : BookImage}
              alt="The Minimalist Entrepreneur"
              loading="lazy"
            />
          </a>
          <h1>Ask My Book</h1>
        </div>
        </div>
    );
  }
  
  export default Header;
