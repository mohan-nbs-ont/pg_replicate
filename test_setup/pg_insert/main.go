package main

import (
	"context"
	"fmt"
	"os"

	"github.com/jackc/pgx/v4"
)

func main() {

	if len(os.Args) != 3 {
		fmt.Println("usage:", os.Args[0], "book", "author")
		return
	}

	book := os.Args[1]
	author := os.Args[2]

	//postgres://testdb_owner:welcome@127.0.0.83:5432/testdb?sslmode=disable
	conn, err := pgx.Connect(context.Background(), os.Getenv("SRC_DB_URL"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to connect to database: %v\n", err)
		os.Exit(1)
	}
	defer conn.Close(context.Background())

	var string_out string
	err = conn.QueryRow(context.Background(), "INSERT INTO books (id, title, primary_author) VALUES (nextval('books_sequence'), $1, $2)", book, author).Scan(&string_out)

	fmt.Println("record inserted: ", book, author, string_out)
}
