/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

document.addEventListener("DOMContentLoaded", () => {

    const navItems = document.querySelectorAll(".nav-item");
    const toggles = document.querySelectorAll(".drop-toggle");

    // Cerrar todos los menús
    function cerrarMenus(excepto = null) {

        navItems.forEach(item => {

            if (item !== excepto) {

                item.classList.remove("active");

                const button = item.querySelector(".drop-toggle");

                button.setAttribute("aria-expanded", "false");
            }

        });

    }

    // Abrir o cerrar el menú seleccionado
    toggles.forEach(button => {

        button.addEventListener("click", (event) => {

            event.stopPropagation();

            const item = button.closest(".nav-item");

            const estabaAbierto = item.classList.contains("active");

            // Cerrar los demás menús
            cerrarMenus();

            // Alternar el menú seleccionado
            if (!estabaAbierto) {

                item.classList.add("active");

                button.setAttribute("aria-expanded", "true");

            }

        });

    });

    // Cerrar al hacer clic fuera del menú
    document.addEventListener("click", (event) => {

        if (!event.target.closest(".navbar-clinica")) {
            cerrarMenus();
        }

    });

    // Cerrar al seleccionar una opción
    document.querySelectorAll(".dropdown-menu a").forEach(link => {

        link.addEventListener("click", () => {
            cerrarMenus();
        });

    });

    // Cerrar con la tecla Escape
    document.addEventListener("keydown", (event) => {

        if (event.key === "Escape") {

            const menuAbierto = document.querySelector(".nav-item.active");

            if (menuAbierto) {

                const button = menuAbierto.querySelector(".drop-toggle");

                cerrarMenus();

                button.focus();

            }

        }

    });

});

