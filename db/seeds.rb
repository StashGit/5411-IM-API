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


Brand.create_with(
  name: "Nike",
  user_id: User.first.id).find_or_create_by(name: "Nike")

