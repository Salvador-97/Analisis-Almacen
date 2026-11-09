const layout = document.querySelector("svg")
let ubicacionSeleccionada = ""

layout.addEventListener("click", event => {
    if(event.target.tagName === "rect"){
        ubicacionSeleccionada = event.target.id;
        const cuadro = document.getElementById(ubicacionSeleccionada)
        if(cuadro.classList.contains("seleccionado")){
            cuadro.classList.remove("seleccionado")
        } else {
            cuadro.classList.add("seleccionado")
        }
    } else {
        console.log("Elemento no valido")
    }
    
})