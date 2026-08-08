from flask import Flask, render_template_string, request, redirect, url_for, session

app = Flask(__name__)
app.secret_key = "multi-cloud-devops-car-shopping-secret"

cars = [
    {
        "id": 1,
        "name": "Toyota Fortuner",
        "category": "SUV",
        "price": 3500000,
        "original_price": 3900000,
        "rating": 4.8,
        "image": "https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800"
    },
    {
        "id": 2,
        "name": "BMW 3 Series",
        "category": "Luxury",
        "price": 6200000,
        "original_price": 6800000,
        "rating": 4.7,
        "image": "https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800"
    },
    {
        "id": 3,
        "name": "Mercedes-Benz C-Class",
        "category": "Luxury",
        "price": 5800000,
        "original_price": 6400000,
        "rating": 4.8,
        "image": "https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800"
    },
    {
        "id": 4,
        "name": "Hyundai Creta",
        "category": "SUV",
        "price": 1800000,
        "original_price": 2100000,
        "rating": 4.5,
        "image": "https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800"
    },
    {
        "id": 5,
        "name": "Audi A4",
        "category": "Luxury",
        "price": 5200000,
        "original_price": 5700000,
        "rating": 4.6,
        "image": "https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800"
    },
    {
        "id": 6,
        "name": "Mahindra Thar",
        "category": "Off-Road",
        "price": 1700000,
        "original_price": 1950000,
        "rating": 4.7,
        "image": "https://images.unsplash.com/photo-1519245659620-e859806a8d3b?w=800"
    }
]


HTML = """
<!DOCTYPE html>
<html>
<head>

<title>Multi Cloud Motors</title>

<style>

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: Arial, sans-serif;
}

body {
    background: #f1f3f6;
    color: #212121;
}

/* HEADER */

.header {
    background: #111827;
    color: white;
    padding: 15px 5%;
    display: flex;
    align-items: center;
    gap: 25px;
    position: sticky;
    top: 0;
    z-index: 1000;
}

.logo {
    font-size: 25px;
    font-weight: bold;
    min-width: 230px;
}

.logo span {
    color: #ffb300;
}

.search {
    flex: 1;
    display: flex;
    max-width: 650px;
}

.search input {
    width: 100%;
    padding: 13px;
    border: none;
    outline: none;
    font-size: 15px;
}

.search button {
    width: 55px;
    border: none;
    background: #ffb300;
    color: #111;
    font-size: 18px;
    cursor: pointer;
}

.header-button {
    background: #ffb300;
    color: #111;
    padding: 11px 25px;
    font-weight: bold;
    border: none;
    cursor: pointer;
}

.cart {
    font-weight: bold;
    white-space: nowrap;
}

/* CATEGORIES */

.categories {
    background: white;
    padding: 17px 5%;
    display: flex;
    justify-content: center;
    gap: 55px;
    box-shadow: 0 2px 4px #ddd;
}

.category {
    cursor: pointer;
    font-weight: bold;
}

.category:hover {
    color: #ff8f00;
}

/* HERO */

.hero {
    margin: 18px auto;
    width: 90%;
    min-height: 300px;

    background:
        linear-gradient(
            120deg,
            rgba(17,24,39,.95),
            rgba(31,41,55,.85)
        );

    color: white;
    border-radius: 8px;

    display: flex;
    align-items: center;
    justify-content: space-between;

    padding: 55px;
}

.hero h1 {
    font-size: 45px;
    margin-bottom: 15px;
}

.hero p {
    font-size: 19px;
    margin-bottom: 25px;
}

.hero button {
    background: #ffb300;
    color: #111;
    border: none;
    padding: 14px 30px;
    font-weight: bold;
    font-size: 16px;
    cursor: pointer;
}

.car-icon {
    font-size: 130px;
}

/* PRODUCTS */

.container {
    width: 90%;
    margin: auto;
}

.section {
    background: white;
    margin-bottom: 20px;
    padding: 20px;
}

.section-title {
    font-size: 25px;
    font-weight: bold;
    margin-bottom: 20px;
}

.products {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
}

.product {
    background: white;
    border: 1px solid #eee;
    padding: 12px;
    transition: .2s;
}

.product:hover {
    transform: translateY(-5px);
    box-shadow: 0 5px 20px #ddd;
}

.product img {
    width: 100%;
    height: 220px;
    object-fit: cover;
}

.product-name {
    font-weight: bold;
    font-size: 18px;
    margin: 12px 0;
}

.category-label {
    color: #777;
    margin-bottom: 8px;
}

.rating {
    display: inline-block;
    background: #388e3c;
    color: white;
    padding: 5px 8px;
    font-size: 12px;
    border-radius: 3px;
}

.price {
    font-size: 21px;
    font-weight: bold;
    margin-top: 10px;
}

.old-price {
    color: #878787;
    text-decoration: line-through;
    margin-left: 7px;
    font-size: 13px;
}

.discount {
    color: #388e3c;
    font-size: 13px;
    margin-top: 5px;
}

.add-cart {
    width: 100%;
    margin-top: 12px;
    padding: 11px;
    border: none;
    background: #ffb300;
    color: #111;
    font-weight: bold;
    cursor: pointer;
}

/* FOOTER */

footer {
    margin-top: 30px;
    background: #111827;
    color: white;
    padding: 40px 8%;
}

.footer-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 30px;
}

footer h3 {
    color: #ffb300;
    margin-bottom: 15px;
}

footer p {
    margin: 8px 0;
    color: #ddd;
}

/* RESPONSIVE */

@media(max-width: 900px) {

    .products {
        grid-template-columns: repeat(2, 1fr);
    }

    .header {
        flex-wrap: wrap;
    }

    .logo {
        min-width: auto;
    }
}

@media(max-width: 600px) {

    .products {
        grid-template-columns: 1fr;
    }

    .categories {
        gap: 20px;
        overflow-x: auto;
        justify-content: flex-start;
    }

    .hero {
        padding: 30px;
    }

    .hero h1 {
        font-size: 30px;
    }

    .car-icon {
        display: none;
    }

    .footer-grid {
        grid-template-columns: 1fr 1fr;
    }
}

</style>

</head>

<body>


<!-- HEADER -->

<div class="header">

    <div class="logo">
        Multi Cloud <span>Motors</span>
    </div>

    <form class="search" method="GET" action="/">

        <input
            type="text"
            name="search"
            placeholder="Search cars, SUVs, luxury cars..."
            value="{{ search }}"
        >

        <button type="submit">
            🔍
        </button>

    </form>

    <button class="header-button">
        Login
    </button>

    <div class="cart">
        🛒 Cart ({{ cart_count }})
    </div>

</div>


<!-- CATEGORIES -->

<div class="categories">

    <div class="category">🚗 All Cars</div>
    <div class="category">🚙 SUVs</div>
    <div class="category">🏎️ Luxury</div>
    <div class="category">⚡ Electric</div>
    <div class="category">🏁 Sports</div>
    <div class="category">🔥 Offers</div>

</div>


<!-- HERO -->

<div class="hero">

    <div>

        <h1>
            Find Your Dream Car
        </h1>

        <p>
            Explore premium cars, SUVs and luxury vehicles.
        </p>

        <button>
            EXPLORE CARS
        </button>

    </div>

    <div class="car-icon">
        🚘
    </div>

</div>


<!-- PRODUCTS -->

<div class="container">

<section class="section">

    <div class="section-title">
        🔥 Top Deals on Cars
    </div>

    <div class="products">

        {% for car in cars %}

        <div class="product">

            <img
                src="{{ car.image }}"
                alt="{{ car.name }}"
            >

            <div class="product-name">
                {{ car.name }}
            </div>

            <div class="category-label">
                {{ car.category }}
            </div>

            <span class="rating">
                {{ car.rating }} ★
            </span>

            <div class="price">

                ₹{{ "{:,}".format(car.price) }}

                <span class="old-price">
                    ₹{{ "{:,}".format(car.original_price) }}
                </span>

            </div>

            <div class="discount">

                {{
                    ((car.original_price - car.price)
                    / car.original_price * 100)
                    | round
                }}% off

            </div>

            <form method="POST" action="/add/{{ car.id }}">

                <button class="add-cart">
                    ADD TO CART
                </button>

            </form>

        </div>

        {% endfor %}

    </div>

</section>

</div>


<!-- FOOTER -->

<footer>

<div class="footer-grid">

    <div>

        <h3>ABOUT</h3>

        <p>About Multi Cloud Motors</p>

        <p>Careers</p>

        <p>Car Community</p>

    </div>


    <div>

        <h3>HELP</h3>

        <p>Car Finance</p>

        <p>Test Drive</p>

        <p>Shipping</p>

        <p>FAQ</p>

    </div>


    <div>

        <h3>POLICY</h3>

        <p>Terms of Use</p>

        <p>Privacy Policy</p>

        <p>Security</p>

    </div>


    <div>

        <h3>CONTACT</h3>

        <p>support@multicloudmotors.com</p>

        <p>Car & DevOps Support</p>

    </div>

</div>

</footer>


</body>

</html>
"""


@app.route("/", methods=["GET"])
def home():

    search = request.args.get("search", "").strip()

    if search:

        filtered_cars = [
            car for car in cars
            if search.lower() in car["name"].lower()
            or search.lower() in car["category"].lower()
        ]

    else:

        filtered_cars = cars

    cart = session.get("cart", [])

    return render_template_string(
        HTML,
        cars=filtered_cars,
        search=search,
        cart_count=len(cart)
    )


@app.route("/add/<int:car_id>", methods=["POST"])
def add_to_cart(car_id):

    cart = session.get("cart", [])

    cart.append(car_id)

    session["cart"] = cart

    return redirect(url_for("home"))


@app.route("/cart")
def cart():

    cart = session.get("cart", [])

    cart_cars = [
        car
        for car in cars
        if car["id"] in cart
    ]

    total = sum(
        car["price"]
        for car in cart_cars
    )

    items = "".join(
        f"""
        <div class="item">
            {car['name']} -
            ₹{car['price']:,}
        </div>
        """
        for car in cart_cars
    )

    if not items:
        items = "<p>Your cart is empty.</p>"

    return f"""
    <html>

    <head>

        <title>Car Shopping Cart</title>

        <style>

            body {{
                font-family: Arial;
                background: #f1f3f6;
                padding: 40px;
            }}

            .cart {{
                background: white;
                padding: 30px;
                max-width: 800px;
                margin: auto;
            }}

            h1 {{
                color: #111827;
            }}

            .item {{
                padding: 15px;
                border-bottom: 1px solid #ddd;
            }}

            .total {{
                font-size: 25px;
                font-weight: bold;
                margin-top: 20px;
            }}

            a {{
                color: #ff8f00;
            }}

        </style>

    </head>

    <body>

        <div class="cart">

            <h1>🚗 Your Car Cart</h1>

            {items}

            <div class="total">
                Total: ₹{total:,}
            </div>

            <br>

            <a href="/">
                ← Continue Shopping
            </a>

        </div>

    </body>

    </html>
    """


if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=False
    )