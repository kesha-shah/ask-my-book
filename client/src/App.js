import {
  createBrowserRouter,
  createRoutesFromElements,
  Route,
  RouterProvider,
} from "react-router-dom";

// pages
import Home from "./pages/Home";
import NotFound from "./pages/NotFound";

// layouts
import RootLayout from "./layouts/RootLayout";
const router = createBrowserRouter(
  createRoutesFromElements(

      <Route path="/" element={<RootLayout />}>
        <Route index element={<Home />} />
        <Route path="ask" element={<Home />} />
        <Route path="question" element={<Home />}>
          <Route path=":id" element={<Home />} />
        </Route>
        <Route path="*" element={<NotFound />} />
      </Route>

  )
);

function App() {

  return <RouterProvider router={router} />;
}

export default App;
