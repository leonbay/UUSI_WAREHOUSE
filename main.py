from google.cloud import secretmanager
import requests
import psycopg2
from datetime import datetime

#main function where everything happens
def get_order(request):
    #customer_id = "2"
    request_json = request.get_json(silent=True)
    request_args = request.args

    if request_json and 'customer_id' in request_json:
        customer_id = request_json['customer_id']
    elif request_args and 'customer_id' in request_args:
        customer_id = request_args['customer_id']
    else:
        customer_id = 'Customer_id missing' 

    if customer_id == 'Customer_id missing':
        return customer_id
    
    customer_id = str(customer_id)
    order_id = make_order_info(customer_id)
    print(order_id)
    lista = []
    lista = get_items(customer_id)
    print(lista)
    input_order_items(lista,order_id)
    delete_from_shoppincart(customer_id)
    return "Order finished. You will get confirmation soon."

#5delete from ShoppingChard (with customerID, orderID)
def delete_from_shoppincart(customer_id:str):
    client = secretmanager.SecretManagerServiceClient()
    ip2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-ipv42/versions/latest"})
    ip = ip2.payload.data.decode("UTF-8")

    pw2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-password2/versions/latest"})
    pw = pw2.payload.data.decode("UTF-8")

    sqluser2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-user2/versions/latest"})
    sqluser = sqluser2.payload.data.decode("UTF-8")
    
    con = psycopg2.connect(host=(ip), database = "piirakka", port=5432, user=(sqluser),password=(pw))
    cur = con.cursor()
    SQL = 'DELETE FROM shoppingcart WHERE customer_id = %s;'
    a = (customer_id, )
    cur.execute(SQL,a)
    con.commit()

#4input Order_items: orderID,productID,amount,price
def input_order_items(lista:list, order_id:str):
    client = secretmanager.SecretManagerServiceClient()
    ip2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-ipv42/versions/latest"})
    ip = ip2.payload.data.decode("UTF-8")

    pw2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-password2/versions/latest"})
    pw = pw2.payload.data.decode("UTF-8")

    sqluser2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-user2/versions/latest"})
    sqluser = sqluser2.payload.data.decode("UTF-8")
    
    for item in lista:
        b= item[1]
        c=item[2]
        print("B item is",b)
        print("C item is", c)
        print("product order id is ", order_id)
        con = psycopg2.connect(host=(ip), database = "piirakka", port=5432, user=(sqluser),password=(pw))
        cur = con.cursor()
        SQL = 'INSERT INTO order_items(order_info_id, product_id, amount) VALUES (%s,%s,%s);'
        x = (order_id,b,c, )
        print("X is:", x)
        cur.execute(SQL,x)
        con.commit()



#3get from ShoppingChard (with customeriID, input from user) productID, amount,
def get_items(customer_id:int):
    client = secretmanager.SecretManagerServiceClient()
    ip2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-ipv42/versions/latest"})
    ip = ip2.payload.data.decode("UTF-8")

    pw2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-password2/versions/latest"})
    pw = pw2.payload.data.decode("UTF-8")

    sqluser2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-user2/versions/latest"})
    sqluser = sqluser2.payload.data.decode("UTF-8")
    
    con = psycopg2.connect(host=(ip), database = "piirakka", port=5432, user=(sqluser),password=(pw))
    cur = con.cursor()
    SQL = 'SELECT * FROM shoppingcart WHERE customer_id = %s;'
    a = (customer_id, )
    cur.execute(SQL,a)
    row = cur.fetchone()
    #print(row)
    list_of_products = []
    while row is not None:
        #print(f"{row[1]}, {row[2]}, {row[3]}")
        list_of_products.append([row[1],row[2],row[3]])
        row = cur.fetchone()
    cur.close()
    con.close()
    return list_of_products

#makes new order to order_info table and returns the order ID
def make_order_info(customer_id:str):
    client = secretmanager.SecretManagerServiceClient()
    ip2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-ipv42/versions/latest"})
    ip = ip2.payload.data.decode("UTF-8")

    pw2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-password2/versions/latest"})
    pw = pw2.payload.data.decode("UTF-8")

    sqluser2 = client.access_secret_version(request={"name": "projects/29618385328/secrets/sql-user2/versions/latest"})
    sqluser = sqluser2.payload.data.decode("UTF-8")
    con = psycopg2.connect(host=(ip), database = "piirakka", port=5432, user=(sqluser),password=(pw))
    cur = con.cursor()
    #now = datetime.now()
    #print(now)
    #order_time = now.strftime('%Y-%m-%d %H:%M')
    #print(order_time)
    #customerID = 2
    #customer_id = 2

    SQL = 'INSERT INTO order_info(customer_id) VALUES (%s)'
    cur.execute(SQL,(customer_id,))
    

    SQL = 'SELECT id FROM order_info WHERE customer_id = %s ORDER BY created_at DESC LIMIT 1'
    cur.execute(SQL,(customer_id,))
    order_id = cur.fetchone()[0]
    
    con.commit()
    cur.close()
    return order_id
    
    