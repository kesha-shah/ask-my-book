import axios from "axios";
import { useParams, Form, useNavigate, useLocation } from "react-router-dom";
import { useEffect, useState } from "react";
import Typewriter from "../helper/Typewriter";
import Header from '../layouts/Header';
import Footer from '../layouts/Footer';

const BOOK_URL =  "/book";
const ASK_URL =  "/book/ask";
const QUESTION_URL = "/book/question";


const getQuestion = async(id) => {
  const response = await axios
    .get(QUESTION_URL + "/" + id, { validateStatus: false });
  return response;
}

const getBook = async () => {
  const response = await axios.get(BOOK_URL);
  return response.data;
}

export default function Home() {
  console.log(`Inside home`)
  const navigate = useNavigate();
  const { id } = useParams();
  const [question, setQuestion] = useState("");
  const [book, setBook] = useState("")
  const [answer, setAnswer] = useState("");
  const [waiting_for_answer, setWaitingForAnswer] = useState("");
  const location = useLocation(); 
  console.log(`book url is ${book.purchase_link} and image path is ${book.image_path}`)

  
  useEffect(() => {
    console.log("Inside Use Effect")
    if (location.pathname === '/') {
     // Make API call to backend server's /book endpoint
      getBook()
        .then(book => {
          console.log(`main book url is ${book.purchase_link} and image path is ${book.image_path}`)
        setBook(book);
        setQuestion(book.current_question);
    })
        .catch(error => {
          // Handle error
          console.error(error);
        });
    }    

    if (id && id > 0) {    
      getQuestion(id).then((response) => {
        if (response.status === 200) {
          setQuestion(response.data.current_question);
          setAnswer(response.data.answer);
          setWaitingForAnswer(false);
        } else {
          navigate(`/question-not-found`);
        }
      });
      if(!book){
        getBook()
        .then(book => {
          console.log(`inside question book url is ${book.purchase_link} and image path is ${book.image_path}`)

        setBook(book);
    })
    }

}
}, []);

  
  const ask = async (question) => {
    const response = await axios.post(ASK_URL, { question });
    setAnswer(response.data.answer);
    setWaitingForAnswer(false);
    navigate(`/question/${response.data.id}`);
  }

  const handleSubmit = (event) => {
    event.preventDefault();
    setWaitingForAnswer(true);
    const question = event.target.elements.question.value;
    ask(question);
  };

  const handleLuckyClick = () => {
    var lucky_question = question;
    setWaitingForAnswer(true);
    do {
      const random = Math.floor(Math.random() * book.lucky_questions.length);
      lucky_question = book.lucky_questions[random];
    } while (lucky_question === question);
    setQuestion(lucky_question);
    ask(lucky_question);
  };

  const handleAskAnotherClick = () => {
    navigate(`/`);
    //location.setpathname(`/`)
    setAnswer(null);
    const textarea = document.querySelector("textarea");
    textarea.select();
  };

  return (
    <div className="home">
      <Header image = {book.image_path} book_url={book.purchase_link} />
      <div className="main">
        <Form onSubmit={handleSubmit}>
          <textarea name="question" required defaultValue={question} />
          {answer ? (
            <div className="buttons" />
          ) : (
            <div className="buttons">
              <button
                id="ask-button"
                type="submit"
                disabled={waiting_for_answer}
              >
                Ask question
              </button>
              <button
                id="lucky-button"
                type="button"
                style={{
                  background: "#eee",
                  borderColor: "#eee",
                  color: "#444",
                }}
                onClick={handleLuckyClick}
                disabled={waiting_for_answer}
              >
                I'm feeling lucky
              </button>
            </div>
          )}
        </Form>

        {answer ? (
          <p id="answer-container">
            <strong>Answer:</strong> <Typewriter text={answer} />
            <br />
            <button id="ask-another-button" onClick={handleAskAnotherClick}>
              Ask another question
            </button>
          </p>
        ) : (
          <p />
        )}
      </div>
      <Footer />

    </div>
  );
}
