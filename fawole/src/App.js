import Header from "./Components/Header";
import Form from "./Components/Form";
import { useState } from "react";
import TodoList from "./Components/TodoList";  // Corrected the import

function App() {
  const [todo, setTodo] = useState("");
  const [todolist, setTodoList] = useState([]);

  return (
    <div className="App">
      <Header />
      <Form
        todo={todo}
        setTodo={setTodo}
        todoList={todolist}
        setTodoList={setTodoList}
      />
      <TodoList setTodoList={setTodoList} todoList={todolist} /> 
    </div>
  );
}

export default App;

