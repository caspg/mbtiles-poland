package main

import (
	"database/sql"
	"log"
	"math"
	"net/http"
	"os"
	"path"
	"strconv"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	_ "github.com/mattn/go-sqlite3"
)

var DB *sql.DB

func main() {
	ConnectDatabase()
	router := gin.Default()

	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET"},
		AllowHeaders:     []string{"Origin", "Accept", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))

	router.GET("/mbtiles/ping", pingHandler)
	router.GET("/mbtiles/:z/:x/:y", tileHandler)

	router.Run(":6060")
}

func ConnectDatabase() error {
	ex_path, err := os.Executable()

	if err != nil {
		log.Println(err)
	}

	dir_path := path.Dir(ex_path)
	db_path := path.Join(dir_path, "..", "data", "bike_infra.mbtiles")

	println(db_path)

	db, err := sql.Open("sqlite3", db_path)
	if err != nil {
		log.Fatal(err)
	}

	DB = db
	return nil
}

func pingHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"message": "pong",
	})
}

func tileHandler(c *gin.Context) {
	sqlStatement, err := DB.Prepare("SELECT tile_data FROM tiles WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?")

	if err != nil {
		log.Println(err.Error())
		internalServerError(c)
		return
	}

	z, x, y := parseZXY(c.Param("z"), c.Param("x"), c.Param("y"))

	var tile_data []byte
	sqlErr := sqlStatement.QueryRow(z, x, y).Scan(&tile_data)

	if sqlErr != nil {
		if sqlErr == sql.ErrNoRows {
			log.Println(sqlErr.Error())
			notFound(c)
			return
		}

		internalServerError(c)
		return
	}

	c.Header("Content-Encoding", "gzip")
	c.Data(http.StatusOK, "application/octet-stream", tile_data)
}

func parseZXY(z string, x string, y string) (int, int, int) {
	parsed_z, _ := strconv.Atoi(z)
	parsed_x, _ := strconv.Atoi(x)
	parsed_y, _ := strconv.Atoi(y)

	// https://stackoverflow.com/a/53801783/4490927
	tms_y := int(math.Pow(2, float64(parsed_z)) - 1 - float64(parsed_y))

	return parsed_z, parsed_x, tms_y
}

func notFound(c *gin.Context) *gin.Context {
	c.JSON(http.StatusNotFound, gin.H{"error": "Not found"})
	return c
}

func internalServerError(c *gin.Context) *gin.Context {
	c.JSON(http.StatusInternalServerError, gin.H{"error": "Unrecognized server error"})
	return c
}
