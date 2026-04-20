package pack;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/Serv")
public class Serv extends HttpServlet {
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String param1 = request.getParameter("nb1");
        String param2 = request.getParameter("nb2");       
        String resultat = "";
    
            double operande1 = Double.parseDouble(param1);
            double operande2 = Double.parseDouble(param2);        
            double somme = operande1 + operande2;                
            resultat = "<html><body>La somme de " + operande1 + " et " + operande2 + " est : " + somme + "</body></html>";
            
        // response.getWriter().println(resultat);
        request.setAttribute("resultat", resultat);
        RequestDispatcher dispatcher = request.getRequestDispatcher("calculatrice.jsp");
        dispatcher.forward(request, response);
        
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }
}