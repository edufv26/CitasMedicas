/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
function mostrarCamposExtra() {
            var tipo = document.getElementById("tipo").value;
            var divDentista = document.getElementById("seccion-dentista");
            var divSecretaria = document.getElementById("seccion-secretaria");

            // Ocultar ambos por defecto al cambiar
            divDentista.style.display = "none";
            divSecretaria.style.display = "none";

            // Mostrar según la opción seleccionada
            if (tipo === "2") {
                divDentista.style.display = "block";
            } else if (tipo === "3") {
                divSecretaria.style.display = "block";
            }
        }

