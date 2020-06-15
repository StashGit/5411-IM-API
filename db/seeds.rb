JOHNS_EMAIL   = "john@example.com"
MARTINS_EMAIL = "martin@the5411.com"
SOFIS_EMAIL   = "sofi@the5411.com"
ANDREWS_EMAIL = "aalonso@stash.com.ar"

User.create_with(first_name: "John", last_name: "Doe",
  email: JOHNS_EMAIL, password: "123",
  password_confirmation: "123").find_or_create_by(email: JOHNS_EMAIL)

User.create_with(first_name: "Martin", last_name: "Martin",
  email:    MARTINS_EMAIL,
  password: "Martin2020!",
  password_confirmation: "Martin2020!").find_or_create_by(email: MARTINS_EMAIL)

User.create_with(first_name: "Sofi", last_name: "Sofi",
  email:    SOFIS_EMAIL,
  password: "sofi2020!",
  password_confirmation: "sofi2020!").find_or_create_by(email: SOFIS_EMAIL)

User.create_with(first_name: "Andres", last_name: "Alonso",
  email:    ANDREWS_EMAIL,
  password: "Password1!",
  password_confirmation: "Password1!").find_or_create_by(email: ANDREWS_EMAIL)

# --- New users

User.create_with(first_name: "Manuel", last_name: "Manuel",
  email: "manuel@the5411.com",
  password: "Manuel2020!",
  password_confirmation: "Manuel2020!").
    find_or_create_by(email: "manuel@the5411.com")

User.create_with(first_name: "Agostina", last_name: "Agostina",
  email: "agostina@the5411.com",
  password: "Agostina2020!",
  password_confirmation: "Agostina2020!").
    find_or_create_by(email: "agostina@the5411.com")

User.create_with(first_name: "Agustina", last_name: "Agustina",
  email: "a.caminos@the5411.com",
  password: "Agustina2020!",
  password_confirmation: "Agustina2020!").
    find_or_create_by(email: "a.caminos@the5411.com")

# ---

Brand.create_with(
  name: "Nike",
  user_id: User.first.id).find_or_create_by(name: "Nike")


unless Qrcode.any?
  # Estos QRs nos permiten probar la impresion sin tener que importar
  # productos.
  1.upto 21 do |i|
    qr = Qrcode.create!(brand_id: Brand.first.id,
      style: "STYLE #{i}",
      color: i % 2 == 0 ? "BLUE" : "RED",
      size:  i % 3 == 0 ? "S" : "M")
    qr.create_img
  end
end




