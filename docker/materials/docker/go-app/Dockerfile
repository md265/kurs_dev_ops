FROM golang:1.24 AS build

LABEL maintainer="ererer"

RUN apt-get update && \
    apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

# kod kopiujemy na koniec, bo bedzie sie czesto zmienial
COPY cmd/ ./cmd/
COPY pkg/ ./pkg/

RUN CGO_ENABLED=0 go build -o ./api cmd/web/main.go


# Stage 2
FROM gcr.io/distroless/static-debian12
# kopiujemy z poprzedniego stage-a
COPY --from=build /src/api /app/api

# uzytkownik w kontenerze
USER nonroot

EXPOSE 8080

ENTRYPOINT ["/app/api"]