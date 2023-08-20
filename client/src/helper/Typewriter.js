import React, { useState, useEffect } from "react";

function randomInteger(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

const Typewriter = ({ text }) => {
  const [currentText, setCurrentText] = useState("");
  const [currentIndex, setCurrentIndex] = useState(0);

  useEffect(() => {
    if (currentIndex < text.length) {
      const timeout = setTimeout(() => {
        setCurrentText((prevText) => prevText + text[currentIndex]);
        setCurrentIndex((prevIndex) => prevIndex + 1);
      }, randomInteger(10, 20));

      return () => clearTimeout(timeout);
    }
  }, [currentIndex, text]);

  return <span>{currentText}</span>;
};

export default Typewriter;
