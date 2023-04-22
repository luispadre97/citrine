require "./Zippy/*"

app = Zippy::App.new

app.get("/") do |context|
  context.response.content_type = "text/plain"
  context.response.print "Hola, bienvenido al servidor Zippy!"
end

app.get("/saludo") do |context|
  context.response.content_type = "text/plain"
  context.response.print "¡Hola! Este es un saludo desde el servidor Zippy."
end

app.post("/submit") do |context, data|
  case data
  when .is_a?(JSON::Any)
    # Procesar contenido JSON
    context.response.print "JSON recibido: #{data}"
  when .is_a?(HTTP::FormData::Part)
    # Procesar la parte del formulario
    context.response.print "Formulario recibido: #{data.name} - #{data.body.gets_to_end}"
  end
end

app.put("/update") do |context, data|
  case data
  when .is_a?(JSON::Any)
    # Procesar contenido JSON
    context.response.print "JSON recibido para actualizar: #{data}"
  when .is_a?(HTTP::FormData::Part)
    # Procesar la parte del formulario
    context.response.print "Formulario recibido para actualizar: #{data.name} - #{data.body.gets_to_end}"
  end
end

app.delete("/borrar") do |context|
  context.response.content_type = "text/plain"
  context.response.print "Borrar información."
end

app.run
