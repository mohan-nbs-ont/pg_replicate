package main

import (
	"context"
	"database/sql"
	"fmt"
	"github.com/go-pg/pg"
	_ "github.com/lib/pq"
	"io"
	"os"
	"strconv"
	"time"
)

func read_src_write_dst(src_query, dst_query string) {
	src_db, src_err := pg.ParseURL(os.Getenv("SRC_DB_URL"))
	if src_err != nil {
		panic(src_err)
	}
	src_db_conn := pg.Connect(src_db)
	src_db_ctx := context.Background()
	var src_db_out string
	_, src_db_conn_err := src_db_conn.QueryOneContext(src_db_ctx, pg.Scan(&src_db_out), "SELECT version()")
	if src_db_conn_err != nil {
		panic(src_db_conn_err)
	}
	dst_db, dst_err := pg.ParseURL(os.Getenv("DST_DB_URL"))
	if dst_err != nil {
		panic(dst_err)
	}
	dst_db_conn := pg.Connect(dst_db)
	dst_db_ctx := context.Background()
	var dst_db_out string
	_, dst_db_conn_err := dst_db_conn.QueryOneContext(dst_db_ctx, pg.Scan(&dst_db_out), "SELECT version()")
	if dst_db_conn_err != nil {
		panic(dst_db_conn_err)
	}

	// pipe used to transfer from reader to writer
	r, w := io.Pipe()

	writer := make(chan error)
	go func() {
		// wait for last write to close before exiting main
		defer w.Close()
		_, err := src_db_conn.CopyTo(w, src_query)
		writer <- err
	}()

	reader := make(chan error)
	go func() {
		_, err := dst_db_conn.CopyFrom(r, dst_query)
		reader <- err
	}()

	errWriter := <-writer
	if errWriter != nil {
		fmt.Println("Writer (CopyTo) error:", errWriter)
	}

	errReader := <-reader
	if errReader != nil {
		fmt.Println("Reader (CopyFrom) error: ", errReader)
	}

	if errWriter == nil && errReader == nil {
		fmt.Println("INFO: batch completed without errors")
	} else {
		fmt.Println("ERROR: batch completed with errors")
	}
}

func get_cur_id(tbl, id, db_url string) int {
	// database connection settings - using lib/pq
	db, err := sql.Open("postgres", db_url)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	// database connection test
	err = db.Ping()
	if err != nil {
		fmt.Println("ERROR: db connect fail")
		panic(err)
	}
	fmt.Println("INFO: db connect success")

	// get last tx id in table
	sqlStatement := "SELECT " + id + " FROM " + tbl + " ORDER BY " + id + " DESC LIMIT 1;"
	var cur_id int
	row := db.QueryRow(sqlStatement)
	switch err := row.Scan(&cur_id); err {
	case sql.ErrNoRows:
		cur_id = 0
	case nil:
	default:
		panic(err)
	}
	return cur_id
}

func main() {

	threads := 30
	cnt := 0

	if len(os.Args) != 5 {
		fmt.Println("usage:", os.Args[0], "src-table", "src-id", "dst-table", "dst-id")
		return
	}

	src_tbl := os.Args[1]
	src_id := os.Args[2]
	dst_tbl := os.Args[3]
	dst_id := os.Args[4]
	fmt.Println("INFO: start time", time.Now())
	fmt.Println("INFO: user input provided:", src_tbl, src_id, dst_tbl, dst_id)

	src_cur_id := get_cur_id(src_tbl, src_id, os.Getenv("SRC_DB_URL"))
	fmt.Println("GOT SRC CUR ID:", src_cur_id)

	dst_cur_id := get_cur_id(dst_tbl, dst_id, os.Getenv("DST_DB_URL"))
	fmt.Println("GOT DST CUR ID:", dst_cur_id)

	cur_diff := (src_cur_id - dst_cur_id)
	cur_remain := (src_cur_id - cur_diff)
	fmt.Println("CUR DIFF & CUR REMAIN:", cur_diff, cur_remain)

	//case: cur_diff
	//      if is 0 , do nothing
	//      if >0, run and replicate to secondary
	//             find the value to start off from
	//      if <0, something wrong, the secondary has more records than the primary
	//      if no value (blank) or any other non int is returned, general error

	switch {
	case cur_diff == 0:
		fmt.Println("Nothing to do\n")
	case cur_diff > 0:
		for cnt < threads {

			fmt.Println("\n*****************************************************************************")
			fmt.Println("INFO: batch start", time.Now())

			src_query := "COPY (SELECT * FROM " + src_tbl + " WHERE " + src_id + " > " +
				strconv.Itoa(cur_remain) + " and " + src_id + "%" + strconv.Itoa(threads) +
				" = " + strconv.Itoa(cnt) + ") TO STDOUT"

			dst_query := "COPY " + dst_tbl + " FROM STDIN"

			fmt.Println("INFO: source database batch query: ", src_query)
			fmt.Println("INFO: destination database batch query: ", dst_query)
			read_src_write_dst(src_query, dst_query)

			cnt++
		}

	case cur_diff < 0:
		fmt.Println("ERROR: destination database has more records than the source database. logical error\n")
	default:
		fmt.Println("ERROR: id counts returned unexpected value, general error, check database logs\n")
	}

}
