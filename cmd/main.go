package main

import (
	"encoding/json"
	"net/http"
	"os"

	"fmt"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/codepipeline"
)

type list struct {
	pipeStates map[string]map[string]string
}

func main() {
	r := mux.NewRouter()

	var NotImplemented = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Not Implemented"))
	})

	//List := map[string]map[string]string{"name1": map[string]string{
	//	"name": "yep",
	//}}

	var ListHandler = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		enableCors(&w)

		setupResponse(&w, r)
		if (*r).Method == "OPTIONS" {
			return
		}

		vars := mux.Vars(r)
		slug := vars["slug"]
		//w.Write([]byte(slug))
		List := getStates(slug)
		payload, _ := json.Marshal(List)

		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(payload))

	})
	r.Handle("/list", ListHandler).Methods("GET")
	r.Handle("/list/{slug}", ListHandler).Methods("GET")
	r.Handle("/", NotImplemented).Methods("GET")
	http.ListenAndServe(":3000", handlers.LoggingHandler(os.Stdout, r))
}
func enableCors(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
}
func setupResponse(w *http.ResponseWriter, req *http.Request) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	(*w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
}

func getStates(filter string) map[string]map[string]string {
	fmt.Println("filtering for: ", filter)
	sess := session.Must(session.NewSession(&aws.Config{
		Region: aws.String("eu-central-1"),
	}))
	svc := codepipeline.New(sess)
	lpOut, err := svc.ListPipelines(&codepipeline.ListPipelinesInput{})
	if err != nil {
		fmt.Println(err)
	}
	finalList := make(map[string]map[string]string)

	for _, entry := range lpOut.Pipelines {
		//fmt.Println(*entry.Name)
		gpOut, err := svc.GetPipelineState(&codepipeline.GetPipelineStateInput{
			Name: entry.Name,
		})
		if err != nil {
			fmt.Println(err)
		}
		//fmt.Println(gpOut)
		List := make(map[string]string)
		for _, newEntry := range gpOut.StageStates {
			fmt.Println(*entry.Name + "-" + *newEntry.StageName + "status: " + *newEntry.LatestExecution.Status)
			List[*newEntry.StageName] = *newEntry.LatestExecution.Status
		}
		finalList[*entry.Name] = List
	}
	fmt.Println("final List: ", finalList)
	return finalList
}
